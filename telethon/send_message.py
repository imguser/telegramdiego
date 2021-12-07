#!/usr/bin/env python3

import os
import sys
import json
from telethon import TelegramClient, sync, utils
from telethon import functions, types
from telethon.sessions import StringSession
from telethon.tl.types import InputPeerUser


def send_message(mode, user_id, access_hash, message):
    client = TelegramClient(session, api_id, api_hash)
    try:
        client.start(phone=phone_number)
        receiver = None
        if mode == 'username':
            receiver = client.get_input_entity(user_id)
        elif mode == 'id':
            receiver = InputPeerUser(int(user_id), int(access_hash))

        client.send_message(receiver, message, parse_mode='md', link_preview=False)
    finally:
        client.disconnect()


if __name__ == '__main__':
    mode, user_id, access_hash, message = None, None, None, None

    if len(sys.argv) == 4:
        _, mode, user_id, message = sys.argv
    elif len(sys.argv) > 4:
        _, mode, user_id, access_hash, message = sys.argv

    api_id = os.environ['TELEGRAM_API_ID']
    api_hash = os.environ['TELEGRAM_API_HASH']
    phone_number = os.environ['TELEGRAM_PHONE']
    session = os.environ.get('TELEGRAM_SESSION') or StringSession(os.environ['TELEGRAM_SESSION_STRING'])

    send_message(mode, user_id, access_hash, message)
