#!/usr/bin/env python3
"""
Simple Alpaca Paper Trading Script
Usage:
  python trade.py buy AAPL 1
  python trade.py sell AAPL 1
  python trade.py positions
  python trade.py orders
"""

import sys
import json
import urllib.request
import urllib.error

ENDPOINT = "https://paper-api.alpaca.markets/v2"
KEY      = "PKDI4C64OJVXLVSOKTEAJ336IN"
SECRET   = "CvbdmE6SRJXahh8akidWmCJ4bPDRVymustMkiJHVp1T8"

HEADERS = {
    "APCA-API-KEY-ID": KEY,
    "APCA-API-SECRET-KEY": SECRET,
    "Content-Type": "application/json"
}


def request(method, path, data=None):
    url = f"{ENDPOINT}{path}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=HEADERS, method=method)
    try:
        with urllib.request.urlopen(req) as res:
            return json.loads(res.read())
    except urllib.error.HTTPError as e:
        return json.loads(e.read())


def place_order(side, symbol, qty):
    result = request("POST", "/orders", {
        "symbol": symbol.upper(),
        "qty": str(qty),
        "side": side,
        "type": "market",
        "time_in_force": "day"
    })
    print(json.dumps(result, indent=2))


def get_positions():
    result = request("GET", "/positions")
    if not result:
        print("No open positions.")
        return
    for p in result:
        print(f"  {p['symbol']}: {p['qty']} shares @ avg ${float(p['avg_entry_price']):.2f} | P&L: ${float(p['unrealized_pl']):.2f}")


def get_orders():
    result = request("GET", "/orders?status=all&limit=10")
    if not result:
        print("No orders found.")
        return
    for o in result:
        print(f"  [{o['status']}] {o['side'].upper()} {o['qty']} {o['symbol']} @ {o['type']}")


if __name__ == "__main__":
    args = sys.argv[1:]

    if not args:
        print(__doc__)
        sys.exit(0)

    cmd = args[0].lower()

    if cmd in ("buy", "sell"):
        if len(args) < 3:
            print(f"Usage: python trade.py {cmd} SYMBOL QTY")
            sys.exit(1)
        place_order(cmd, args[1], args[2])

    elif cmd == "positions":
        get_positions()

    elif cmd == "orders":
        get_orders()

    else:
        print(f"Unknown command: {cmd}")
        print(__doc__)
