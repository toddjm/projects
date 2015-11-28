#!/usr/bin/env python

"""
Canonical example for retrieving information
from Facebook.

"""

import simplejson
import sys
import urllib2


def main():
    """Access Facebook data via Graph API."""

    user_id = ''
    access_token = ('')

    try:
        # Get list of friend id numbers.
        url = ('https://graph.facebook.com/' +
               user_id +
               '/friends?access_token='
               + access_token)
        id_numbers = simplejson.loads(urllib2.urlopen(url).read())
        id_numbers = [i['id'] for i in id_numbers['data']]
    except urllib2.HTTPError:
        sys.exit()

    node = {}
    for i in id_numbers:
        try:
            url = ('https://graph.facebook.com/me/mutualfriends/' +
                   i +
                   '/?access_token=' +
                   access_token)
            j = simplejson.loads(urllib2.urlopen(url).read())
            node[i] = [k['id'] for k in j['data']]
        except urllib2.HTTPError:
            pass

    # 1st deg edges: intersection of mutual friends for all friends.
    edge = {}
    for i in node:  # {id_number: [nodes with edges]}
        values = []  # collect edge nodes for id
        for k in node[i]:  # [id_numbers for edges]
            for l in [x for x in id_numbers if x != i]:
                if k in node[l]:  # if value[i] in value[l]: 1st degree edge
                    values.append(l)
        edge[i] = values

    fname = 'filename'
    with open(fname, 'w') as outf:
        for i in edge:
            outf.write(i, edge[i] + '\n')


if __name__ == "__main__":
    main()
