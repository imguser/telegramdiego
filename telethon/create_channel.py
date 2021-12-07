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

def setup_channel(chname, bots):
    results = []
    with TelegramClient(session, api_id, api_hash) as client:
        client.start(phone=phone_number)
        results.append(client(functions.channels.CreateChannelRequest(title=chname, about='')))

        channel_id = results[-1].chats[0].id

        # grand all bots admin rights
        results.append([
            client(
                functions.channels.EditAdminRequest(
                    channel=channel_id,
                    user_id=bot,
                    admin_rights=ADMIN_RIGHTS,
                    rank='adminbot',
                )
            )
            for bot in bots
        ])

    return results


if __name__ == '__main__':
    _, chname, *bots = sys.argv

    api_id = os.environ['TELEGRAM_API_ID']
    api_hash = os.environ['TELEGRAM_API_HASH']
    phone_number = os.environ['TELEGRAM_PHONE']
    session = os.environ.get('TELEGRAM_SESSION') or StringSession(os.environ['TELEGRAM_SESSION_STRING'])
    results = setup_channel(chname, bots)
    data = {}
    try:
        data = {"channel": chname, "id": "-100%s" % results[0].chats[0].id, "bots": bots}
    except:
        pass

    print(json.dumps(data))
