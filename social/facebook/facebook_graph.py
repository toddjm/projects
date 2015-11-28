#!/usr/bin/env python
"""
Canonical example for retrieving information
from Facebook.

"""

import simplejson
import urllib2


def main():
    """Access Facebook data via Graph API."""
    # Access token for session.
    token = ('')

    # Retrieve friends.
    url = ('https://graph.facebook.com/me/friends?access_token=' + token)

    content = simplejson.loads(urllib2.urlopen(url).read().encode('utf-8'))

    # content['data'] is list of dicts with keys 'name' and 'id'
    for i in content['data']:
        url = ('https://graph.facebook.com/' + i['id'] + '/?access_token=' +
               token)
        j = simplejson.loads(urllib2.urlopen(url).read().encode('utf-8'))
        print j['name'].encode('utf-8')

if __name__ == "__main__":
    main()
