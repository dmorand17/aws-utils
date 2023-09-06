import json
import logging
import os
import sys
from json import JSONEncoder

import boto3
import click
from tabulate import tabulate

"""
This script will allow the user to retrieve various SSM parameters.  
The initial use case around this was to pull Ubuntu 22.04 AMIs across all AWS regions

Example paths:
Ubuntu AMI: /aws/service/canonical/ubuntu/server/22.04/stable/current
Amazon Linux AMI: /aws/service/amazon-linux-latest/

Author: Doug Morand
"""

# Logging
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
logger = logging.getLogger(__name__)
logger.addHandler(handler)
logger.setLevel(logging.INFO)

SERVICE_PATH_LIST = [
    "/aws/service/ami-windows-latest/",
    "/aws/service/canonical/",
    "/aws/service/debian/",
    "/aws/service/freebsd/",
    "/aws/service/redhat/",
    "/aws/service/suse/",
    "/aws/service/ami-amazon-linux-latest/",
    "/aws/service/ami-macos-latest/",
]


class MyEncoder(JSONEncoder):
    def default(self, obj):
        return obj.__dict__


class Table:
    def __init__(self, header, table_data=[]):
        self.table_data = table_data
        self.header = header
        self.add_row(header)

    def add_row(self, row):
        self.table_data.append(row)

    def print(self, **kwargs):
        # print(tabulate(self.table_data, headers="firstrow", tablefmt="fancy_grid"))
        print(tabulate(self.table_data, headers="firstrow", **kwargs))


class RegionParameters:
    def __init__(self, region, parameters=[]):
        self.region_name = region
        self.parameters = parameters

    def __repr__(self):
        class_name = type(self).__name__
        return f"{class_name}(region={self.region_name}, parameters={self.parameters})"

    def __str__(self):
        return f"{self.region_name} with {str(len(self.parameters))} parameters"

    def add_parameters(self, parameter):
        self.parameters.extend(parameter)


class AllRegionParameters:
    def __init__(self):
        self.parameters_by_region = {}
        pass

    def add_region_parameters(self, region_parameters):
        logger.debug(f"Adding: {region_parameters}")
        self.parameters_by_region[region_parameters.region_name] = {}
        self.parameters_by_region[region_parameters.region_name] = {
            "region_name": region_parameters.region_name,
            "Parameters": region_parameters.parameters,
        }

    def __str__(self):
        return json.dumps(
            dict(self.parameters_by_region), ensure_ascii=False, cls=MyEncoder
        )

    def __repr__(self):
        return self.__str__()


def get_regions(sort=True):
    """
    Get a list of regions and optionally sort

    :param sort: sort the list of regions
    """
    parameters = get_parameters(
        path="/aws/service/global-infrastructure/services/ssm/regions",
    )
    if sort:
        return [
            param["Value"] for param in sorted(parameters, key=lambda x: x["Value"])
        ]
    return [param["Value"] for param in parameters["Parameters"]]


def get_parameters(path, region=os.environ.get("AWS_REGION"), **kwargs):
    """
    Get parameter values from SSM

    :param path: path to query
    :param region: region to query
    :param kwargs: additional kwargs to pass to the get_parameters_by_path function

    """
    parameters = []
    ssm_client = boto3.client("ssm", region_name=region)
    try:
        paginator = ssm_client.get_paginator("get_parameters_by_path")
        page_iterator = paginator.paginate(Path=path, **kwargs)

        for idx, page in enumerate(page_iterator):
            logger.debug(f"Processing page '{str(idx)}'")

            params = [
                {
                    "Name": parameter["Name"],
                    "Value": parameter["Value"],
                    "DataType": parameter["DataType"],
                }
                for parameter in page["Parameters"]
            ]
            parameters.extend(params)
    except Exception as e:
        logger.error(f"[{region}] Error getting parameters from path: {path}")
        logger.error(e)
    return parameters


def process_region_parameters(regions, path, output_format):
    logger.debug(f"Regions: {regions}")
    all_region_param_list = AllRegionParameters()
    for region in regions:
        # print(f"[✓] Checking {region}")
        parameters = get_parameters(path, region=region, Recursive=True)
        logger.debug(json.dumps(parameters, indent=4, sort_keys=True))
        region_parameters = RegionParameters(region, parameters)

        all_region_param_list.add_region_parameters(region_parameters)

    if output_format == "table":
        table = Table(["region", "name", "datatype", "value"])

        for region in all_region_param_list.parameters_by_region:
            [
                table.add_row([region, p["Name"], p["DataType"], p["Value"]])
                for p in all_region_param_list.parameters_by_region[region][
                    "Parameters"
                ]
            ]

        table.print(tablefmt="fancy_grid")

    if output_format == "json":
        # print("[-] Parameters")
        logger.debug(all_region_param_list)
        print(
            json.dumps(
                dict(all_region_param_list.parameters_by_region),
                indent=2,
                cls=MyEncoder,
            )
        )


def generate_region_parameter_list():
    pass


# @click.command(no_args_is_help=True)
@click.command()
@click.option(
    "-r",
    "--region",
    default=lambda: os.environ.get("AWS_REGION", ""),
    show_default="AWS_REGION",
    help="Region to query",
)
@click.option("-a", "--all-regions", is_flag=True, help="Query all regions")
@click.option(
    "-f",
    "--format",
    "output_format",
    type=click.Choice(["table", "json"]),
    default="json",
    show_default=True,
    help="Output format",
)
@click.option(
    "-p",
    "--path",
    required=True,
    help="Parameter path to query in SSM. e.g. /aws/service/canonical/ubuntu",
)
@click.option("-v", "--verbose", is_flag=True, help="Print debug messages")
def cli(region, all_regions, output_format, path, verbose):
    # Set logging
    if verbose:
        logger.setLevel(logging.DEBUG)

    if not path.startswith("/"):
        print(f"[!] '{path}' is not a valid path.  Must start with '/'")
        sys.exit(1)

    regions = get_regions() if all_regions else [region]
    process_region_parameters(regions, path, output_format)


if __name__ == "__main__":
    cli()
