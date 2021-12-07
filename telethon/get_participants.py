#!/usr/bin/env python3

import os
import sys
import json
import logging
from functools import wraps
from telethon import TelegramClient, sync, utils
from telethon import functions, types
from telethon.tl.types import InputPeerChannel
from telethon.tl.functions.channels import GetParticipantsRequest
from telethon.tl.types import ChannelParticipantsSearch
from telethon.sessions import StringSession
from time import sleep


def get_participants(channel_id, access_hash, invite_link):

    with TelegramClient(session, api_id, api_hash) as client:
        channel_id = channel_id.replace('-100', '')
        channel = None
        if access_hash:
            try:
                channel = InputPeerChannel(int(channel_id), int(access_hash))
            except:
                pass

        if  not channel and invite_link:
            try:
                channel = client.get_entity(invite_link)
            except:
                pass

        if not channel:
            channel = client.get_entity(channel_id)

        users = client.get_participants(channel, aggressive=True)
        users_data = [
            dict(
                id=u.id,
                first_name=u.first_name,
                last_name=u.last_name,
                username=u.username,
                language_code=u.lang_code,
                access_hash=u.access_hash,
                is_bot=u.bot,
            )
            for u in users
        ]
        return {
            'id': channel_id,
            'access_hash': channel.access_hash,
            'users': users_data,
        }


if __name__ == '__main__':
    channel_id, access_hash, invite_link = None, None, None

    if len(sys.argv) == 3:
        _, channel_id, invite_link = sys.argv
    elif len(sys.argv) > 3:
        _, channel_id, access_hash, invite_link = sys.argv

    api_id = os.environ['TELEGRAM_API_ID']
    api_hash = os.environ['TELEGRAM_API_HASH']
    phone_number = os.environ['TELEGRAM_PHONE']
    session = os.environ.get('TELEGRAM_SESSION') or StringSession(os.environ['TELEGRAM_SESSION_STRING'])

    data = get_participants(channel_id, access_hash, invite_link)

    print(json.dumps(data))
