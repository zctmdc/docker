#!/usr/bin/env python
# coding=utf-8

import logging
logging.basicConfig(
    format="%(funcName)-18s - %(levelname)8s : %(message)s",
    datefmt="%Y-%m-%d  %H:%M:%S %a",
)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
