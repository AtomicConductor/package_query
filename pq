#!/usr/bin/env python


"""
Query package versions
"""

import json
import urllib2

def run(product_list, product_obj):
    """
    Allow user to choose a product to print versions for.

    product_list is a simple list of product names.
    product_obj has product names as keys and version arrays as values.
    """
    for i, p in enumerate(product_list):
        print "{:2d}. {}".format(i, p)

    num_products = len(product_list)
    range_str = "(0..{:d})".format(num_products-1)
    choice = int(input(
        "Enter the number of the package you want version info for {}: ".format(range_str)))

    while choice not in range(len(product_list)):
        choice = int(
            raw_input("Invalid choice, try again {}:".format(range_str)))

    print "You chose: '{}'".format(product_list[choice])

    if choice == 0:
        requested = product_list[1:]
    else:
        requested = [product_list[choice]]

    for product_name in requested:
        print product_name
        for ver in product_obj[product_name]:
            print ver
        print ""


def main():
    """
    Fetch and prepare packages data for user to query.

    User may make repeated queries. 
    """

    url = 'https://dev-dashboard.conductortech.com/api/v1/ee/packages'
    content = urllib2.urlopen(url).read()
    packages = json.loads(content)["data"]

    product_obj = {}
    for package in packages:
        product = package["product"]
        if product not in product_obj:
            product_obj[product] = []
        version = ".".join(
            [v for v in [
                package["major_version"],
                package["minor_version"],
                package["release_version"],
                package["build_version"]] if v != ""]
        )
        product_obj[product].append(version)

    for product in product_obj:
        product_obj[product] = sorted(list(set(product_obj[product])))

    product_list = ["all"]
    for p in sorted(product_obj.keys()):
        product_list.append(p)

    while True:
        run(product_list, product_obj)
        go = raw_input("Make another query? (y/n): ")
        if go.lower().startswith("n"):
            exit(0)

main()
