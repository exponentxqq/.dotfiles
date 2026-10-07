/**
 * `/git/events` route tests: one subscription watches every `path` query
 * parameter, the first poll reports every watched path, and a later poll
 * reports only the paths whose status digest actually changed. The route is
 * driven through a fake request/response pair with fake timers, so the 30s poll
 * interval costs no wall time.
 * @module dsh-git-graph-multi/test/host-events-route
 */

import { realpath } from 'node:fs/promises'
import path from 'node:path'
import { afterEach, describe, expect, it, vi } from 'vitest'
import {
  headBranchArgv, headShortArgv, operationMarkersArgv, statusPorcelainArgv, topLevelArgv,
} from '../src/core/git-command.ts'
import { buildWorkspaceGate, GitService, type GitRunner } from '../src/host/git-service.ts'
import { registerGitRoutes } from '../src/host/routes.ts'
import { cleanup, makeDirs, runnerKey, scriptedRunner, tempDir, type ScriptedAnswers } from './support.ts'

/** Fixture roots created by a test, removed when it finishes. */
const roots: string[] = []

/**
 * Real macrotask scheduler captured before the fake timers take over: the poll
 * awaits real filesystem I/O (realpath), which fake timers do not drive, so a
 * test has to hand the event loop back for those callbacks to run.
 */
const realImmediate = setImmediate

/** Let every pending real-I/O callback (and its continuations) settle. */
async function flushIo(turns = 60): Promise<void> {
  for (let index = 0; index < turns; index++) {
    await new Promise<void>((resolve) => { realImmediate(() => { resolve() }) })
  }
}

afterEach(async () => {
  vi.useRealTimers()
  await Promise.all(roots.splice(0).map(async root => await cleanup(root)))
})

/** A throwaway canonical directory, so fixture paths match realpath output. */
async function fixtureDir(prefix: string): Promise<string> {
  const dir = await realpath(await tempDir(prefix))
  roots.push(dir)
  return dir
}

/** Script the five git reads one repository status needs. */
function statusAnswers(
  answers: ScriptedAnswers,
  root: string,
  status: { branch?: string; porcelain?: string; head?: string; marker?: string } = {},
): void {
  answers[runnerKey(root, topLevelArgv())] = { stdout: `${root}\n` }
  answers[runnerKey(root, headBranchArgv())] = { stdout: `${status.branch ?? 'main'}\n` }
  answers[runnerKey(root, statusPorcelainArgv())] = { stdout: status.porcelain ?? '' }
  answers[runnerKey(root, operationMarkersArgv())] = { stdout: status.marker ?? '' }
  answers[runnerKey(root, headShortArgv())] = { stdout: `${status.head ?? 'abc1234'}\n` }
}

/** A response double recording everything the SSE handler writes. */
interface FakeResponse {
  statusCode: number
  headers: Record<string, string>
  chunks: string[]
  writeHead(code: number, headers?: Record<string, string>): FakeResponse
  write(chunk: string): boolean
  end(): void
  on(): void
}

function fakeResponse(): FakeResponse {
  return {
    statusCode: 0,
    headers: {},
    chunks: [],
    writeHead(code, headers) {
      this.statusCode = code
      Object.assign(this.headers, headers ?? {})
      return this
    },
    write(chunk) {
      this.chunks.push(chunk)
      return true
    },
    end() {},
    on() {},
  }
}

/** A loopback GET request double (the trust fence reads the socket and Host header). */
function fakeRequest(url: string) {
  return {
    url,
    method: 'GET',
    headers: { host: '127.0.0.1:3080' },
    socket: { remoteAddress: '127.0.0.1' },
    on() { return this },
  }
}

/** Capture the registered routes so a test can invoke the SSE handler directly. */
function fakeCtx() {
  const handlers = new Map<string, unknown>()
  return {
    handlers,
    ctx: {
      logger: { warn: () => {} },
      webServer: {
        register: (route: { path: string; handler: unknown }) => {
          handlers.set(route.path, route.handler)
          return () => {}
        },
      },
    },
  }
}

/** The `event: change` payloads written to the response, in order. */
function changePayloads(res: FakeResponse): Array<{ paths: string[] }> {
  return res.chunks
    .filter(chunk => chunk.startsWith('event: change'))
    .map(chunk => JSON.parse(chunk.slice(chunk.indexOf('data: ') + 6)) as { paths: string[] })
}

describe('/git/events multi-repository subscription', () => {
  it('watches every path and pushes only the paths that changed', async () => {
    vi.useFakeTimers()
    const workspace = await fixtureDir('ggm-events-ws-')
    await makeDirs(workspace, ['.git', 'service/.git'])
    const serviceRepo = path.join(workspace, 'service')
    const answers: ScriptedAnswers = {}
    statusAnswers(answers, workspace, { branch: 'main' })
    statusAnswers(answers, serviceRepo, { branch: 'feat/x' })
    const runner: GitRunner = scriptedRunner(answers)
    const service = new GitService(runner, buildWorkspaceGate({ list: () => [{ path: workspace }] }))
    const { ctx, handlers } = fakeCtx()
    registerGitRoutes(ctx as never, service)
    const handler = handlers.get('/git/events') as (req: unknown, res: unknown) => void

    const res = fakeResponse()
    handler(fakeRequest(`/git/events?path=${encodeURIComponent(workspace)}&path=${encodeURIComponent(serviceRepo)}`), res)
    expect(res.statusCode).toBe(200)
    expect(res.headers['content-type']).toContain('text/event-stream')

    // First poll: both paths are new, so both are reported in one push.
    await vi.advanceTimersByTimeAsync(30_000)
    await flushIo()
    const first = changePayloads(res)
    expect(first).toHaveLength(1)
    expect([...first[0].paths].sort()).toEqual([workspace, serviceRepo].sort())

    // A steady poll with no digest change pushes nothing.
    res.chunks.length = 0
    await vi.advanceTimersByTimeAsync(30_000)
    await flushIo()
    expect(changePayloads(res)).toHaveLength(0)

    // Only the service repository moved: only that path is reported.
    answers[runnerKey(serviceRepo, headBranchArgv())] = { stdout: 'feat/y\n' }
    res.chunks.length = 0
    await vi.advanceTimersByTimeAsync(30_000)
    await flushIo()
    const second = changePayloads(res)
    expect(second).toHaveLength(1)
    expect(second[0].paths).toEqual([serviceRepo])
  })

  it('keeps a single-path subscription working', async () => {
    vi.useFakeTimers()
    const workspace = await fixtureDir('ggm-events-single-')
    await makeDirs(workspace, ['.git'])
    const answers: ScriptedAnswers = {}
    statusAnswers(answers, workspace, { branch: 'main' })
    const service = new GitService(scriptedRunner(answers), buildWorkspaceGate({ list: () => [{ path: workspace }] }))
    const { ctx, handlers } = fakeCtx()
    registerGitRoutes(ctx as never, service)
    const handler = handlers.get('/git/events') as (req: unknown, res: unknown) => void

    const res = fakeResponse()
    handler(fakeRequest(`/git/events?path=${encodeURIComponent(workspace)}`), res)
    await vi.advanceTimersByTimeAsync(30_000)
    await flushIo()
    const payloads = changePayloads(res)
    expect(payloads).toHaveLength(1)
    expect(payloads[0].paths).toEqual([workspace])
  })

  it('rejects a subscription without any path', async () => {
    const workspace = await fixtureDir('ggm-events-empty-')
    await makeDirs(workspace, ['.git'])
    const service = new GitService(scriptedRunner({}), buildWorkspaceGate({ list: () => [{ path: workspace }] }))
    const { ctx, handlers } = fakeCtx()
    registerGitRoutes(ctx as never, service)
    const handler = handlers.get('/git/events') as (req: unknown, res: unknown) => void

    const res = fakeResponse()
    handler(fakeRequest('/git/events'), res)
    expect(res.statusCode).toBe(400)
    expect(res.chunks).toHaveLength(0)
  })
})
