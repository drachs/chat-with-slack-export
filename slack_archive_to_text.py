import json, sys
import os, csv
from pprint import pprint
import re
from datetime import datetime
import glob


def handle_annotated_mention(matchobj):
    return "@{}".format((matchobj.group(0)[2:-1]).split("|")[1])

def handle_mention(matchobj):
    global user
    #print(user[matchobj.group(0)[2:-1]][0])
    try: 
        return "@{}".format(user[matchobj.group(0)[2:-1]][0])
    except:
            return "@UNKNOWN"


def transform_text(text):
    text = text.replace("<!channel>", "@channel")
    text = text.replace("&gt;",  ">")
    text = text.replace("&amp;", "&")
    # Handle "<@U0BM1CGQY|the100rabh> has joined the channel"
    text = re.compile("<@U\w+\|[A-Za-z0-9.-_]+>").sub(handle_annotated_mention, text)
    text = re.compile("<@U\w+>").sub(handle_mention, text)
    return text

jsondir = "docs-json"
outputdir = "docs-txt"
userjson = jsondir + "/users.json"

userlist  = []
user = {}
with open(userjson) as user_data:
    userlist = json.load(user_data)
    for userdata in userlist:
        userid = userdata["id"]
        if "real_name" in userdata and userdata["real_name"]:
            realname = userdata["real_name"]
            if not re.match('.*[a-zA-Z].*', realname) :
                realname = userdata["name"]
        else:
            realname = userdata["name"]
        #print(realname)
        user[userid] = [realname]
for channel_name in os.listdir(jsondir):
    with open(outputdir + "/" + channel_name+".txt", "wb") as output:
        for json_filename in glob.glob(jsondir + '/' + channel_name + '/*.json'):
            with open(json_filename) as json_file_handle:
                data = json.load(json_file_handle)
                print("Parsing: "+json_filename)
                for item in data:
                    if item["type"] == "message" :
                        if item["text"].find("> has joined the channel") == -1:
                            user_cur = user.get(item.get("user", "Unknown User"), [u'Unknown User'])
                            #print(user_cur)
                            #ts = datetime.utcfromtimestamp(float(item['ts']))
                            #time = ts.strftime("%Y-%m-%d %H:%M:%S")
                            item["text"] = transform_text(item["text"])
                            output.write(user_cur[0].encode('utf-8'))
                            output.write(b":")
                            output.write(item['text'].encode('utf-8'))
                            output.write(b"\n")
                            #csvwriter.writerow([time.encode('utf-8'),item['text'].encode('utf-8'),user_cur[0].encode('utf-8')])
            

