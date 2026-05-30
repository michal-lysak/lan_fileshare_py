# This Python file uses the following encoding: utf-8


class State:
    IDLE = "idle"
    DISCOVERING = "discovering"
    CONNECTING = "connecting"
    CONNECTED = "connected"
    TRANSFERING = "transfering"

class ActivityState:
    IDLE = "idle"
    CHOOSING = "choosing"