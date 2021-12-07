#!/usr/bin/env python3

import os
import sys
import json
from telethon import TelegramClient, sync, utils
from telethon import functions, types
from telethon.sessions import StringSession

ADMIN_RIGHTS = types.ChatAdminRights(
    post_messages=True,
    add_admins=False,
    invite_users=True,
    change_info=False,
    ban_users=True,
    delete_messages=False,
    pin_messages=False,
    edit_messages=False,
)

def delete_channel(chname):
    with TelegramClient(session, api_id, api_hash) as client:
        client(functions.channels.DeleteChannelRequest(channel=chname))


if __name__ == '__main__':
    _, chname = sys.argv

    api_id = os.environ['TELEGRAM_API_ID']
    api_hash = os.environ['TELEGRAM_API_HASH']
    phone_number = os.environ['TELEGRAM_PHONE']
    session = os.environ.get('TELEGRAM_SESSION') or StringSession(os.environ['TELEGRAM_SESSION_STRING'])
    try:
        delete_channel(chname)
    except:
        pass
    