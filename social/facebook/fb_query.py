#!/usr/bin/env python

"""
Canonical example for retrieving information
from Facebook.

"""

import datetime
import simplejson
import urllib2


def main():
    """Access Facebook data via Graph API."""

    access_token = ('')

    # Get list of friend id numbers.
    url = ('https://graph.facebook.com/' +
           'fql?q=SELECT uid2 FROM friend WHERE uid1=me()')

    content = simplejson.loads(urllib2.urlopen(url).read())
    content = [i['id'] for i in content['data']]

    connections = ['activities', 'adaccounts', 'albums',
                   'apprequests', 'books', 'checkins', 'events',
                   'family', 'feed', 'friendlists', 'friendrequests',
                   'friends', 'games', 'groups', 'home', 'inbox',
                   'interests', 'likes', 'links', 'locations',
                   'messagingfavorites', 'movies', 'music', 'mutualfriends',
                   'notes', 'notifications', 'outbox', 'payments',
                   'permissions', 'photos', 'posts', 'scores',
                   'statuses', 'tagged', 'television', 'updates', 'videos']

    for i in content:
        node = {}
        timestamp = datetime.datetime.utcnow().strftime("%s.%f")
        node['timestamp'] = timestamp
        url = ('https://graph.facebook.com/' +
               i +
               '/?access_token=' +
               access_token)
        j = simplejson.loads(urllib2.urlopen(url).read())
        node[i] = [{k: j[k]} for k in j.keys()]
        for k in connections:
            if k == 'mutualfriends':
                url = ('https://graph.facebook.com/me/mutualfriends/' +
                       j['id'] +
                       '/?access_token=' +
                       access_token)
            else:
                url = ('https://graph.facebook.com/' +
                       j['id'] +
                       '/' +
                       k +
                       '?access_token='
                       + access_token)
            try:
                #print('{0}: {1}; {2}: {3}').format('connection', k, 'URL', url)
                l = simplejson.loads(urllib2.urlopen(url).read())
                node[k] = [m for m in l['data']]
            except urllib2.HTTPError, e:
                pass
        print(node)


if __name__ == "__main__":
    main()
