import functions_framework

import sys
import os
from typing import Any

from google.cloud import compute_v1

project_id = "merry-christmas-2023-407806"
zone = "us-central1-c"
instance_name = "merry-christmas-2023"


@functions_framework.http
def start_minecraft_server(request):
    headers = {"Access-Control-Allow-Origin": "*"}

    try:
        start_instance(project_id, zone, instance_name)
    except:
        return (
            "Minecraft failed to start. Please ask server admins to check.",
            500,
            headers,
        )
    return ("OK", 200, headers)


def wait_for_extended_operation(
    operation, verbose_name: str = "operation", timeout: int = 300
) -> Any:
    """
    Waits for the extended (long-running) operation to complete.

    If the operation is successful, it will return its result.
    If the operation ends with an error, an exception will be raised.
    If there were any warnings during the execution of the operation
    they will be printed to sys.stderr.

    Args:
        operation: a long-running operation you want to wait on.
        verbose_name: (optional) a more verbose name of the operation,
            used only during error and warning reporting.
        timeout: how long (in seconds) to wait for operation to finish.
            If None, wait indefinitely.

    Returns:
        Whatever the operation.result() returns.

    Raises:
        This method will raise the exception received from `operation.exception()`
        or RuntimeError if there is no exception set, but there is an `error_code`
        set for the `operation`.

        In case of an operation taking longer than `timeout` seconds to complete,
        a `concurrent.futures.TimeoutError` will be raised.
    """
    result = operation.result(timeout=timeout)

    if operation.error_code:
        print(
            f"Error during {verbose_name}: [Code: {operation.error_code}]: {operation.error_message}",
            file=sys.stderr,
            flush=True,
        )
        print(f"Operation ID: {operation.name}", file=sys.stderr, flush=True)
        raise operation.exception() or RuntimeError(operation.error_message)

    if operation.warnings:
        print(f"Warnings during {verbose_name}:\n", file=sys.stderr, flush=True)
        for warning in operation.warnings:
            print(f" - {warning.code}: {warning.message}", file=sys.stderr, flush=True)

    return result


def start_instance(project_id: str, zone: str, instance_name: str) -> None:
    """
    Starts a stopped Google Compute Engine instance (with unencrypted disks).
    Args:
        project_id: project ID or project number of the Cloud project your instance belongs to.
        zone: name of the zone your instance belongs to.
        instance_name: name of the instance your want to start.
    """
    instance_client = compute_v1.InstancesClient()

    operation = instance_client.start(
        project=project_id, zone=zone, instance=instance_name
    )

    wait_for_extended_operation(operation, "instance start")
