#!/usr/bin/env python3

import subprocess
import re
import os.path
import argparse
import sys

from copy import deepcopy
from pprint import pprint

class Entity(object):

    def __init__(self, name, src=None):
        self.name = name.upper()
        self.ports = {'in':[],'out':[]}
        self.src = src

    def print(self):
        print('Entity: ' + self.name)
        print('inputs:')
        pprint(self.ports['in'])
        print('outputs:')
        pprint(self.ports['out'])

class Port(object):

    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return self.name

def parse_entities_from_vhdl(filepath):

    cmd = "ghdl -s -dp {filepath}".format(filepath=filepath)
    cmd += "| egrep 'entity_declaration|interface_signal_declaration|mode' "
    cmd += "| egrep -v 'parent|has_mode'"
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
    entities = process.communicate()[0]

    entity_name_rgx = re.compile('.*entity_declaration.*\'(.*)\'')
    intf_signal_rgx = re.compile('.*interface_signal_declaration.*\'(.*)\'')
    intf_dir_rgx = re.compile('\s+mode:\s+(.*)')

    entity = None
    port = None
    for line in entities.decode().split("\n"):
        match = entity_name_rgx.match(line)
        if match:
            entity = Entity(match.group(1), src=filepath)
            continue
        match = intf_signal_rgx.match(line)
        if match:
            port = Port(match.group(1))
            continue
        match = intf_dir_rgx.match(line)
        if match and port and entity:
            entity.ports[match.group(1)] += [deepcopy(port)]

    return entity

class dot_graph(object):

    def __init__(self, entity):
        self.entity = entity

    def __repr__(self):

        result = ["digraph {name} {{".format(name=self.entity.name)]

        result += ["    graph [ splines=ortho, rankdir=LR];"]
        result += ["    node [ shape=record, fontname=\"monospace\"];"]
        result += ["    compound=true;"]

        port_count = max(len(entity.ports['in']), len(entity.ports['out']))

        result += ["    {entity.name} [ label=\"{entity.name}\", height={port_count}, width=2, fontsize=20 ];".format(entity=self.entity, port_count=port_count-1) ]
        #result += ["    {entity.name} [ label=\"{entity.name}\", xlabel=\"src: {entity.src}\" height={port_count}, width=2, fontsize=30 ];".format(entity=self.entity, port_count=port_count-1) ]

        for input_port in entity.ports['in']:
            result += ["    {port} [ shape=plaintext ];".format(port=input_port.name) ]
            result += ["    {port} -> {name};".format(port=input_port.name, name=self.entity.name) ]

        for output_port in entity.ports['out']:
            result += ["    {port} [ shape=plaintext ];".format(port=output_port.name) ]
            result += ["    {name} -> {port};".format(port=output_port.name, name=self.entity.name) ]

        result += ["}"]
        return "\n".join(result)

def entity_to_dot(entity, output_file):

    graph = dot_graph(entity)

    if output_file == sys.stdout:
        print(graph)
    else:
        with open(output_file, 'w') as output:
            output.write(str(graph))


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("path", help="VHDL file to parse", type=str)

    parser.add_argument("-o", "--output", default=sys.stdout, help="Output path", type=str)

    args = parser.parse_args()

    if args.output != sys.stdout:
       filename = os.path.basename(args.path)
       filename = filename.replace(".vhd", ".dot")
       args.output = os.path.join(args.output, filename)

    entity = parse_entities_from_vhdl(args.path)
    if entity:
        entity_to_dot(entity, args.output)


