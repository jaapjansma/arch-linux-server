#!/usr/bin/env python3
import os
import argparse
import json

parser = argparse.ArgumentParser(description="""
Send e-mails. The messages are stored as flat files in a directory. Where each file is a message.

The format of a message file is that the first line contains the from, the second line the to and the third line the subject and all lines after
will contain the message.
""")
parser.add_argument("--directory", help="The directory which contains the mail messages", type=str, default="/root/mails", required=False)
args = parser.parse_args()

directory = args.directory

for filename in os.listdir(directory):
        path = os.path.join(directory, filename)
        if not os.path.isfile(path):
            continue

        with open(path) as f:
            fromLine = f.readline()
            toLine = f.readline()
            subjectLine = f.readline()
            message = f.read()
            message = message + "\n"

            #os.remove(path)

            os.system(['mail,  '-s "'+subjectLine+'"', toLine], input=message.encode())
