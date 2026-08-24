-- 强制恢复本机声卡的存储 profile / route，忽略 jack 可用性误报
-- 背景：ALC887-VD 前置耳机口 jack 检测在部分启动后误报"未插入"，
-- 导致 wireplumber 拒绝恢复 analog profile / headphones route，输出落到 HDMI。
--
-- 组成：
--   1. force-stored-profile / force-stored-routes：
--      在 stock hook 之前抢先设置 selected-profile / selected-routes，
--      绕过 available ~= "no" 检查。
--   2. watch-profile-mismatch（关键）：
--      启动竞态——首个 select-profile 事件可能在组件全部加载前已派发完成，
--      上面的 hook 会错过。此 watcher 监听 Profile 实际落地结果：
--      若系统应用（save 不为 true）的 profile 与存储值不符，则重新派发
--      select-profile 事件，此时强制 hook 必已注册，可纠偏。
--      用户主动切换（save=true）不干预。

cutils = require ("common-utils")
devinfo = require ("device-info-cache")
log = Log.open_topic ("s-device")

local FORCE_DEVICE = "alsa_card.pci-0000_00_1f.3"

SimpleEventHook {
  name = "device/force-stored-profile",
  before = "device/find-stored-profile",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-profile" },
    },
  },
  execute = function (event)
    if event:get_data ("selected-profile") then return end

    local device = event:get_subject ()
    local dev_name = device.properties["device.name"]
    if dev_name ~= FORCE_DEVICE then return end

    local state = State ("default-profile")
    local profile_name = state:load ()[dev_name]
    if not profile_name then return end

    for p in device:iterate_params ("EnumProfile") do
      local profile = cutils.parseParam (p, "EnumProfile")
      if profile.name == profile_name then
        log:info (device, string.format (
            "force-stored-profile: '%s' (availability check bypassed)", profile_name))
        event:set_data ("selected-profile", profile)
        break
      end
    end
  end
}:register ()

SimpleEventHook {
  name = "device/force-stored-routes",
  before = "device/find-stored-routes",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-routes" },
      Constraint { "profile.changed", "=", "true" },
      Constraint { "profile.active-device-ids", "is-present" },
    },
  },
  execute = function (event)
    local device = event:get_subject ()
    local dev_name = device.properties["device.name"]
    if dev_name ~= FORCE_DEVICE then return end

    local event_properties = event:get_properties ()
    local profile_name = event_properties["profile.name"]
    local active_ids = Json.Raw (event_properties["profile.active-device-ids"]):parse ()
    local selected_routes = event:get_data ("selected-routes") or Properties ()

    local state = State ("default-routes")
    local state_table = state:load ()
    local key = dev_name .. ":profile:" .. profile_name
    local value = state_table[key]
    if not value then return end

    local json = Json.Raw (value)
    if not (json and json:is_array ()) then return end
    local stored = json:parse ()
    if #stored == 0 then return end

    local dev_info = devinfo:get_device_info (device)

    for _, device_id in ipairs (active_ids) do
      if not selected_routes[tostring (device_id)] then
        for _, ri in pairs (dev_info.route_infos) do
          if cutils.arrayContains (ri.devices, tonumber (device_id)) and
              (ri.profiles == nil or cutils.arrayContains (ri.profiles, dev_info.active_profile)) and
              cutils.arrayContains (stored, ri.name) then
            log:info (device, string.format (
                "force-stored-routes: '%s' for device ID %s (availability check bypassed)",
                ri.name, tostring (device_id)))
            selected_routes[tostring (device_id)] =
                Json.Object { index = ri.index }:to_string ()
            break
          end
        end
      end
    end

    event:set_data ("selected-routes", selected_routes)
  end
}:register ()

SimpleEventHook {
  name = "device/watch-profile-mismatch",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "device-params-changed" },
      Constraint { "event.subject.param-id", "=", "Profile" },
    },
  },
  execute = function (event)
    local device = event:get_subject ()
    local dev_name = device.properties["device.name"]
    if dev_name ~= FORCE_DEVICE then return end

    local stored = State ("default-profile"):load ()[dev_name]
    if not stored then return end

    for p in device:iterate_params ("Profile") do
      local prof = cutils.parseParam (p, "Profile")
      if prof then
        if prof.save then return end
        if prof.name ~= stored then
          log:info (device, string.format (
              "watch-profile-mismatch: active='%s' stored='%s', re-pushing select-profile",
              prof.name, stored))
          local source = event:get_source ()
          source:call ("push-event", "select-profile", device, nil)
        end
        return
      end
    end
  end
}:register ()

SimpleEventHook {
  name = "default-nodes/force-configured-sink",
  before = "default-nodes/find-best-default-node",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-default-node" },
    },
  },
  execute = function (event)
    local props = event:get_properties ()
    if props["default-node.type"] ~= "audio.sink" then return end

    local target = State ("default-nodes"):load ()["default.configured.audio.sink"]
    if not target or target == "" then return end

    -- 已在候选列表中则交给 stock 逻辑
    local available = event:get_data ("available-nodes")
    if available then
      local nodes = available:parse ()
      if nodes then
        for _, np in ipairs (nodes) do
          if np["node.name"] == target then return end
        end
      end
    end

    -- 节点确实存在（仅因路由 available=no 被排除）才强制
    local source = event:get_source ()
    local si_om = source:call ("get-object-manager", "session-item")
    for linkable in si_om:iterate {
      type = "SiLinkable",
      Constraint { "media.class", "c", "Audio/Sink", "Audio/Duplex" },
    } do
      local node = linkable:get_associated_proxy ("node")
      if node and node.properties["node.name"] == target then
        log:info (string.format (
            "force-configured-sink: '%s' (route availability bypassed)", target))
        event:set_data ("selected-node", target)
        event:set_data ("selected-node-priority", 40000)
        return
      end
    end
  end
}:register ()

log:info ("force-analog.lua loaded (profile/route force + mismatch watcher)")

-- 启动竞态兜底：首个 select-profile / Profile 参数事件可能在 hook 注册前已完成，
-- 加载 2.5s 后主动核对一次，不符则直接应用存储 profile（不触发用户态存储）。
local boot_om = ObjectManager {
  Interest {
    type = "device",
    Constraint { "device.name", "=", FORCE_DEVICE },
  }
}
boot_om:activate (Features.ALL)

Core.timeout_add (2500, function ()
  for device in boot_om:iterate () do
    local stored = State ("default-profile"):load ()[FORCE_DEVICE]
    if not stored then return end

    for p in device:iterate_params ("Profile") do
      local prof = cutils.parseParam (p, "Profile")
      if prof and not prof.save and prof.name ~= stored then
        for ep in device:iterate_params ("EnumProfile") do
          local eprof = cutils.parseParam (ep, "EnumProfile")
          if eprof and eprof.name == stored then
            log:info (device, string.format (
                "boot-fix: active='%s' stored='%s', applying stored profile",
                prof.name, stored))
            device:set_param ("Profile", Pod.Object {
              "Spa:Pod:Object:Param:Profile", "Profile",
              index = tonumber (eprof.index),
            })
            break
          end
        end
        break
      end
    end
    return
  end
end)
