#!/usr/bin/env python3

import argparse
import subprocess
from neo4j import GraphDatabase
import time

container_name = "neo4j"

# Get container ip
def get_container_ip(container_name):
    command = ["sudo", "lxc-info", "--ips", "--name", container_name]
    try:
        output = subprocess.check_output(command, universal_newlines=True)
        ip_address = output.strip().split()[-1]
        return ip_address
    except subprocess.CalledProcessError as e:
        raise RuntimeError("Failed to get IP address for container") from e

# Configs
uri = "bolt://{0}:7687".format(get_container_ip(container_name))
user = "neo4j"
password = "password"

# Find all children
def find_children(session, node):
    start_time = time.time()
    query = "MATCH (n)-[]->(child) WHERE n.Category = $node RETURN child.Category"
    result = session.run(query, node=node)
    children = [record["child.Category"] for record in result]
    end_time = time.time()
    query_time = end_time - start_time
    return children, query_time

# Count children
def count_children(session, node):
    start_time = time.time()
    query = "MATCH (n)-[]->(child) WHERE n.Category = $node RETURN count(child) AS count"
    result = session.run(query, node=node)
    count = result.single()["count"]
    end_time = time.time()
    query_time = end_time - start_time
    return count, query_time

# Find all grandchildren
def find_grandchildren(session, node):
    start_time = time.time()
    query = "MATCH (n)-[]->(child)-[]->(grandchild) WHERE n.Category = $node RETURN grandchild.Category"
    result = session.run(query, node=node)
    grandchildren = [record["grandchild.Category"] for record in result]
    end_time = time.time()
    query_time = end_time - start_time
    return grandchildren, query_time

# Find all parents
def find_parents(session, node):
    start_time = time.time()
    query = "MATCH (n)<-[]-(parent) WHERE n.Category = $node RETURN parent.Category"
    result = session.run(query, node=node)
    parents = [record["parent.Category"] for record in result]
    end_time = time.time()
    query_time = end_time - start_time
    return parents, query_time

# Count parents
def count_parents(session, node):
    start_time = time.time()
    query = "MATCH (n)<-[]-(parent) WHERE n.Category = $node RETURN count(parent) AS count"
    result = session.run(query, node=node)
    count = result.single()["count"]
    end_time = time.time()
    query_time = end_time - start_time
    return count, query_time

# Find all grandparents
def find_grandparents(session, node):
    start_time = time.time()
    query = "MATCH (n)<-[]-(parent)<-[]-(grandparent) WHERE n.Category = $node RETURN grandparent.Category"
    result = session.run(query, node=node)
    grandparents = [record["grandparent.Category"] for record in result]
    end_time = time.time()
    query_time = end_time - start_time
    return grandparents, query_time

# Count Unique Nodes
def count_unique_nodes(session):
    start_time = time.time()
    query = "MATCH (n) RETURN COUNT(DISTINCT n.Category) AS UniqueNodeCount"
    result = session.run(query)
    count = result.single()["UniqueNodeCount"]
    end_time = time.time()
    query_time = end_time - start_time
    return count, query_time

# Find root Nodes
def find_root_nodes(session):
    start_time = time.time()
    query = "MATCH (n) WHERE NOT (n)<--() RETURN n.Category AS RootNodes"
    result = session.run(query)
    root_nodes = [record["RootNodes"] for record in result]
    end_time = time.time()
    query_time = end_time - start_time
    return root_nodes, query_time

# Find Nodes with most Children
def find_nodes_with_most_children(session):
    start_time = time.time()
    query = """
    MATCH (n)-[]->(child)
    WITH n, COUNT(child) AS children
    ORDER BY children DESC
    RETURN COLLECT(n.Category)[0] AS NodeWithMostChildren, children
    LIMIT 1
    """
    result = session.run(query)
    node_with_most_children = result.single()
    end_time = time.time()
    query_time = end_time - start_time
    return node_with_most_children, query_time

# Find Nodes with least Children
def find_nodes_with_least_children(session):
    start_time = time.time()
    query = """
    MATCH (n)-[]->(child)
    WITH n, COUNT(child) AS children
    WHERE children > 0
    RETURN COLLECT(n.Category)[0] AS NodeWithLeastChildren, children
    ORDER BY children ASC
    LIMIT 1
    """
    result = session.run(query)
    node_with_least_children = result.single()
    end_time = time.time()
    query_time = end_time - start_time
    return node_with_least_children, query_time

# Rename Node
def rename_node(session, old_name, new_name):
    start_time = time.time()
    query = "MATCH (n { Category: $oldName }) SET n.Category = $newName RETURN n"
    result = session.run(query, oldName=old_name, newName=new_name)
    end_time = time.time()
    query_time = end_time - start_time
    return result.single(), query_time

# Find path between Nodes
def find_paths_between_nodes(session, node1, node2):
    start_time = time.time()
    query = """
    MATCH paths = (n {Category: $node1})-[*]->(m {Category: $node2})
    RETURN [p IN nodes(paths) | p.Category] AS path
    """
    result = session.run(query, node1=node1, node2=node2)
    paths = [record["path"] for record in result]
    end_time = time.time()
    query_time = end_time - start_time
    print(f"DEBUG: Paths found: {paths}")  # Debug output
    return paths, query_time

# Main
def main():
    parser = argparse.ArgumentParser(description="CLI tool for interacting with Neo4j database")
    parser.add_argument("type", type=int, choices=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], help="Type of query to execute")
    parser.add_argument("node", type=str, nargs='?', help="Node Category (optional)")
    parser.add_argument("new_name", type=str, nargs='?', help="New name for renaming or destination node for paths (optional)")
    args = parser.parse_args()

    # Connect and execute
    driver = GraphDatabase.driver(uri, auth=(user, password))
    with driver.session() as session:
        if args.type in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]:
            if not args.node:
                print("Error: Node category is required for this query type.")
                return
        if args.type == 1:
            children, query_time = find_children(session, args.node)
            print("Children of node '{}' (Query Time: {:.4f} seconds):".format(args.node, query_time))
            for child in children:
                print(child)
        elif args.type == 2:
            count, query_time = count_children(session, args.node)
            print("Number of children of node '{}' (Query Time: {:.4f} seconds): {}".format(args.node, query_time, count))
        elif args.type == 3:
            grandchildren, query_time = find_grandchildren(session, args.node)
            print("Grandchildren of node '{}' (Query Time: {:.4f} seconds):".format(args.node, query_time))
            for grandchild in grandchildren:
                print(grandchild)
        elif args.type == 4:
            parents, query_time = find_parents(session, args.node)
            print("Parents of node '{}' (Query Time: {:.4f} seconds):".format(args.node, query_time))
            for parent in parents:
                print(parent)
        elif args.type == 5:
            count, query_time = count_parents(session, args.node)
            print("Number of parents of node '{}' (Query Time: {:.4f} seconds): {}".format(args.node, query_time, count))
        elif args.type == 6:
            grandparents, query_time = find_grandparents(session, args.node)
            print("Grandparents of node '{}' (Query Time: {:.4f} seconds):".format(args.node, query_time))
            for grandparent in grandparents:
                print(grandparent)
        elif args.type == 7:
            count, query_time = count_unique_nodes(session)
            print("Unique nodes count: {} (Query Time: {:.4f} seconds)".format(count, query_time))
        elif args.type == 8:
            root_nodes, query_time = find_root_nodes(session)
            print("Root nodes:")
            for node in root_nodes:
                print(node)
            print("(Query Time: {:.4f} seconds)".format(query_time))
        elif args.type == 9:
            most_children, query_time = find_nodes_with_most_children(session)
            print("Node with the most children: {} (Children: {}) (Query Time: {:.4f} seconds)".format(most_children["NodeWithMostChildren"], most_children["children"], query_time))
        elif args.type == 10:
            least_children, query_time = find_nodes_with_least_children(session)
            print("Node with the least children: {} (Children: {}) (Query Time: {:.4f} seconds)".format(least_children["NodeWithLeastChildren"], least_children["children"], query_time))
        elif args.type == 11:
            if args.new_name:
                renamed_node, query_time = rename_node(session, args.node, args.new_name)
                print("Renamed node to: {} (Query Time: {:.4f} seconds)".format(renamed_node["n"]["Category"], query_time))
            else:
                print("Error: New name required for renaming.")
        elif args.type == 12:
            if args.new_name:
                paths, query_time = find_paths_between_nodes(session, args.node, args.new_name)
                print("Paths from {} to {}: (Query Time: {:.4f} seconds)".format(args.node, args.new_name, query_time))
                if paths:
                    for path in paths:
                        print(" -> ".join(path))
                else:
                    print("No path found.")
            else:
                print("Error: Destination node required for path finding.")

    # Close
    driver.close()

# For running directly
if __name__ == "__main__":
    main()
