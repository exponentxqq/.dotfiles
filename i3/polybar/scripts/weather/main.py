import argparse
import os

import requests

OPENWEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"


def load_api_key() -> str:
    # 优先环境变量，其次脚本同目录下的 .api_key 文件（gitignore，不入库）
    key = os.environ.get("OPENWEATHER_API_KEY")
    if key:
        return key
    key_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".api_key")
    try:
        with open(key_file) as f:
            return f.read().strip()
    except OSError:
        return ""


API_KEY = load_api_key()


def get_city() -> str:
    try:
        r = requests.get("https://ipapi.co/json", headers={"User-agent": "Mozilla/5.0"})
        return r.json()["city"]
    except Exception:
        return "london"


def unit_suffix(unit: str) -> str:
    match unit:
        case "metric":
            unit = "ºC"
        case "imperial":
            unit = "ºF"
        case _:
            unit = " K"

    return unit


def wind_dir_cn(deg: float) -> str:
    dirs = ["北", "东北", "东", "东南", "南", "西南", "西", "西北"]
    return dirs[int((deg + 22.5) % 360) // 45]


def get_weather(
    city: str, lang: str, unit: str, api_key: str, extend: bool = False
) -> dict[str, str] | None:
    try:
        r = requests.get(
            f"{OPENWEATHER_URL}?q={city}&lang={lang}&units={unit}&appid={api_key}",
            headers={"User-agent": "Mozilla/5.0"},
        )
        data = r.json()
        temp = data["main"]["temp"]
        desc = data["weather"][0]["description"]
        unit = unit_suffix(unit)

        result = {
            "temp": f"{int(temp)}{unit}",
            "desc": desc.title(),
        }
        if extend:
            feels = int(data["main"]["feels_like"])
            hum = data["main"]["humidity"]
            wind_speed = data["wind"]["speed"]
            wind_deg = data["wind"].get("deg")
            direction = f"{wind_dir_cn(wind_deg)}风" if wind_deg is not None else "风"
            result["extend"] = (
                f"体感{feels}{unit} · {desc.title()} · 湿度{hum}％ · {direction}{wind_speed}m/s"
            )
        return result
    except Exception:
        return None


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Display information about the weather.",
    )
    parser.add_argument(
        "-c",
        metavar="CITY",
        dest="city",
        type=str,
        nargs="+",
        help="city name",
    )
    parser.add_argument(
        "-l",
        metavar="LANG",
        dest="lang",
        type=str,
        nargs=1,
        help="language (en, es, fr, ja, pt, pt_br, ru, zh_cn)",
    )
    parser.add_argument(
        "-u",
        metavar="metric/imperial",
        choices=("metric", "imperial"),
        dest="unit",
        type=str,
        nargs=1,
        help="unit of temperature (default: kelvin)",
    )
    parser.add_argument(
        "-a",
        metavar="API_KEY",
        dest="api_key",
        nargs=1,
        help="API Key",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        dest="verbose",
        help="verbose mode",
    )
    parser.add_argument(
        "-e",
        "--extend",
        action="store_true",
        dest="extend",
        help="extended info (feels like, humidity, wind)",
    )

    args = parser.parse_args()

    api_key = args.api_key[0] if args.api_key else API_KEY
    city = args.city[0] if args.city else get_city()
    lang = args.lang[0] if args.lang else "en"
    unit = args.unit[0] if args.unit else "standard"

    weather = get_weather(city, lang, unit, api_key, extend=args.extend)
    if weather:
        temp, desc = weather["temp"], weather["desc"]
        if args.extend:
            print(f"{temp} {weather['extend']}")
        elif args.verbose:
            print(f"{temp}, {desc}")
        else:
            print(f"{temp}")


if __name__ == "__main__":
    main()

