#!/usr/bin/env python

from urllib3 import exceptions
from kubernetes import config, client, watch
import json
import requests

base_url = 'http://localhost:8181/v1/data/kubernetes/pods'


def add(pod):
    namespace = pod['metadata']['namespace']
    name = pod['metadata']['name']
    print 'upsert /pods/' + namespace + '/' + name
    serialized = json.dumps(pod)
    resp = requests.put(base_url + '/' + namespace + '/' + name, headers={'Content-Type': 'application/json'}, data=serialized)
    if resp.status_code != 204:
        data = resp.json()
        print 'error', data['code'], data['message']


def remove(pod):
    namespace = pod['metadata']['namespace']
    name = pod['metadata']['name']
    print 'remove /pods/' + namespace + '/' + name
    patch = [
        {
            'op': 'remove',
            'path': '/' + namespace + '/' + name,
        }
    ]
    serialized = json.dumps(patch)
    resp = requests.patch(base_url, headers={'Content-Type': 'application/json-patch+json'}, data=serialized)
    if resp.status_code != 204:
        data = resp.json()
        print 'error', data['code'], data['message']


def main():
    config.load_kube_config('/var/run/kubernetes/admin.kubeconfig')
    v1 = client.CoreV1Api()
    result = v1.list_pod_for_all_namespaces()
    print 'Starting with', len(result.items), 'pods'
    w = watch.Watch()
    while True:
        try:
            for event in w.stream(v1.list_pod_for_all_namespaces, _request_timeout=60):
                obj = event['raw_object']
                if event['type'] == 'ADDED':
                    add(obj)
                elif event['type'] == 'MODIFIED':
                    add(obj)
                elif event['type'] == 'DELETED':
                    remove(obj)
        except exceptions.ReadTimeoutError:
            print 'Read timeout'


if __name__ == '__main__':
    main()
