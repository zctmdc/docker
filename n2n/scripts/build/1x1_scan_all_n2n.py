#!/usr/bin/env python
# encoding=utf8

from github import Github
import re
import logging
import json

LOGGER_LEVER = logging.DEBUG

logging.basicConfig(
    format="%(funcName)-16s - %(levelname)8s : %(message)s",
    datefmt="%Y-%m-%d  %H:%M:%S %a",
)
logger = logging.getLogger(__name__)
logger.setLevel(LOGGER_LEVER)


def get_file_info(pattern_name=None, filename=None):
    results = patterns[pattern_name].search(filename)
    if results:
        result = results.group()
        logger.debug(f'{pattern_name}: {result}')
        return result
    else:
        logger.debug(f'{pattern_name}: None')
        return None


if __name__ == '__main__':

    patterns = {
        'compressed_file': re.compile(r'tar|gz|zip|rar'),
        'machine': re.compile(r'(?<=linux_)[a-zA-Z0-9]+'),
        'machine_alias': re.compile(r'(?<=\()[a-zA-Z0-9]+(?=\))'),
        'version_big': re.compile(r'(?<=n2n_)v[0-9a-z]+'),
        'version_small': re.compile(r'(?<=_)v\.?[0-9]\.[0-9]\.[0-9](-[0-9]+)?'),
        'version_commit': re.compile(r'(?<=[0-9]_)(r[0-9]+)')
    }
    dict_os_arch = {
        'x64': "linux/amd64",
        'x86': "linux/386",
        'arm64': "linux/arm64/v8",
        'arm': "linux/arm/v7"
    }
    n2n_obj = {'machine': '', 'machine_alias': '', 'os_arch': '', 'path': '', 'name': '',
               'version_big': '', 'version_small': '', 'fix_version_small': '', 'version_commit': '', 'fix_version_commit': '', 'version_b_s_rc': ''}
    dict_version_b_s_rc = {}
    dict_version_bigs = {}
    # dict_path_bigs = {}

    g = Github()
    repo = g.get_repo("lucktu/n2n")
    base_path = 'Linux'
    contents = repo.get_contents(base_path)
    # dict_path_bigs = {'default': base_path}
    while contents:
        file_content = contents.pop(0)
        if file_content.type == "dir":
            if 'Professional' in file_content.path:
                continue
            contents.extend(repo.get_contents(file_content.path))
            # version_big = get_file_info('version_big', file_content.name)
            # if version_big:
            #     dict_path_bigs = {version_big: file_content.path}
        else:
            filename = file_content.name
            if not patterns['compressed_file'].search(filename):
                logger.debug(f'### {filename}')
                logger.debug('---'*4)
                continue
            logger.info(f'N2N filepath: {file_content.path}')

            machine = get_file_info('machine', filename)
            machine_alias = get_file_info('machine_alias', filename)
            version_big = get_file_info('version_big', filename)
            version_small = get_file_info('version_small', filename)
            fix_version_small = version_small.replace('v.', '').replace(
                'v', '')
            logger.debug(f'fix_version_small: {fix_version_small}')
            version_commit = get_file_info('version_commit', filename)
            if filename == 'n2n_v1_linux_mipsel_v1.3.2_124.zip':
                version_commit = r'r124'
                logger.debug(f'manual version_commit: {version_commit}')

            if version_commit:
                fix_version_commit = version_commit.replace('r', '')
            else:
                fix_version_commit = None

            version_b_s_rc = f'{version_big}_{fix_version_small}'
            if version_commit:
                version_b_s_rc = f'{version_b_s_rc}_{version_commit}'
            logger.debug(f'version_b_s_rc: {version_b_s_rc}')
            logger.debug('---'*4)
            if machine not in dict_os_arch:
                continue
            os_arch = dict_os_arch[machine]
            n2n_obj = {'machine': machine, 'machine_alias': machine_alias, 'os_arch': os_arch,
                       'name': file_content.name, 'path': file_content.path, 'download_url': file_content.download_url,
                       'version_big': version_big,
                       'version_small': version_small, 'fix_version_small': fix_version_small,
                       'version_commit': version_commit, 'fix_version_commit': fix_version_commit,
                       'version_b_s_rc': version_b_s_rc}
            if version_b_s_rc not in dict_version_b_s_rc:
                dict_version_b_s_rc[version_b_s_rc] = {'version_big': version_big,
                                                       'version_small': version_small, 'fix_version_small': fix_version_small,
                                                       'version_commit': version_commit, 'fix_version_commit': fix_version_commit,
                                                       'version_b_s_rc': version_b_s_rc,
                                                       'machines': [],
                                                       'os_archs': [],
                                                       'n2n_objs': [],
                                                       'download_urls': []}
            dict_version_b_s_rc[version_b_s_rc]['n2n_objs'].append(n2n_obj)
            dict_version_b_s_rc[version_b_s_rc]['download_urls'].append(
                file_content.download_url)
            if machine not in dict_version_b_s_rc[version_b_s_rc]['machines']:
                dict_version_b_s_rc[version_b_s_rc]['machines'].append(machine)
            if os_arch not in dict_version_b_s_rc[version_b_s_rc]['os_archs']:
                dict_version_b_s_rc[version_b_s_rc]['os_archs'].append(os_arch)

            if 'Old' in file_content.path:
                continue
            if version_big not in dict_version_bigs:
                dict_version_bigs[version_big] = {'version_big': version_big,
                                                  'version_small': version_small, 'fix_version_small': fix_version_small,
                                                  'version_commit': version_commit, 'fix_version_commit': fix_version_commit,
                                                  'version_b_s_rc': version_big,
                                                  'machines': [],
                                                  'os_archs': [],
                                                  'n2n_objs': [],
                                                  'download_urls': []}

            dict_version_bigs[version_big]['n2n_objs'].append(n2n_obj)
            dict_version_bigs[version_big]['download_urls'].append(
                file_content.download_url)
            if machine not in dict_version_bigs[version_big]['machines']:
                dict_version_bigs[version_big]['machines'].append(machine)
            if os_arch not in dict_version_bigs[version_big]['os_archs']:
                dict_version_bigs[version_big]['os_archs'].append(os_arch)

    logger.debug('---'*8)

    list_build_obj = []

    version_b_s_rcs = list(dict_version_b_s_rc.keys())
    version_b_s_rcs.sort()
    for version_b_s_rc in version_b_s_rcs:
        build_obj = dict_version_b_s_rc[version_b_s_rc]

        list_build_obj.append(build_obj)

    version_bigs = list(dict_version_bigs.keys())
    version_bigs.sort()
    for version_big in version_bigs:
        build_obj = dict_version_bigs[version_big]
        list_build_obj.append(build_obj)

    for build_obj in list_build_obj:
        os_archs = build_obj['os_archs']
        build_version_b_s_rc = build_obj['version_b_s_rc']
        os_archs = build_obj['os_archs']
        download_urls = build_obj['download_urls']

        str_os_archs = ','.join(os_archs)
        build_obj['str_os_archs'] = str_os_archs
        str_download_urls = ','.join(download_urls)
        build_obj['str_download_urls'] = str_download_urls

        logger.debug(f'build_version_b_s_rc: {build_version_b_s_rc}')
        logger.debug(f'build_os_archs: {os_archs}')
        logger.debug(f'str_os_archs: {str_os_archs}')
        logger.debug(f'download_urls: {download_urls}')
        logger.debug(f'str_download_urls: {str_download_urls}')

        logger.debug('---'*4)
    with open('dict_build_obj.json', 'w') as json_file:
        json.dump({'include': list_build_obj},
                  json_file, ensure_ascii=False)
    # e.g.
    # {
    #     'include': [
    #         {
    #             "version_big": "v3",
    #             "version_small": "v3.1.1",
    #             "fix_version_small": "3.1.1",
    #             "version_commit": "r1255",
    #             "fix_version_commit": "1255",
    #             "version_b_s_rc": "v3",
    #             "machines": [
    #                 "arm64",
    #                 "arm",
    #                 "x64",
    #                 "x86"
    #             ],
    #             "os_archs": [
    #                 "linux/arm64/v8",
    #                 "linux/arm/v7",
    #                 "linux/amd64",
    #                 "linux/386"
    #             ],
    #             "n2n_objs": [
    #                 {
    #                     "machine": "x64",
    #                     "machine_alias": null,
    #                     "os_arch": "linux/amd64",
    #                     "name": "n2n_v3_linux_x64_v3.1.1_r1255_static_by_heiye.tar.gz",
    #                     "path": "Linux/n2n_v3_linux_x64_v3.1.1_r1255_static_by_heiye.tar.gz",
    #                     "download_url": "https://raw.githubusercontent.com/lucktu/n2n/master/Linux/n2n_v3_linux_x64_v3.1.1_r1255_static_by_heiye.tar.gz",
    #                     "version_big": "v3",
    #                     "version_small": "v3.1.1",
    #                     "fix_version_small": "3.1.1",
    #                     "version_commit": "r1255",
    #                     "fix_version_commit": "1255",
    #                     "version_b_s_rc": "v3_3.1.1_r1255"
    #                 },
    #                 ...
    #             ],
    #             "download_urls": [
    #                 "https://raw.githubusercontent.com/lucktu/n2n/master/Linux/n2n_v3_linux_x64_v3.1.1_r1255_static_by_heiye.tar.gz",
    #                 ...
    #             ],
    #             "str_os_archs": "linux/arm64/v8,linux/arm/v7,linux/amd64,linux/386",
    #             "str_download_urls": "https://raw.githubusercontent.com/lucktu/n2n/master/Linux/n2n_v3_linux_arm64(aarch64)_v3.1.1_r1255_static_by_heiye.tar.gz,https://raw.githubusercontent.com/lucktu/n2n/master/Linux/n2n_v3_linux_arm_v3.1.1_r1255_static_by_heiye.tar.gz,https://raw.githubusercontent.com/lucktu/n2n/master/Linux/n2n_v3_linux_x64_v3.1.1_r1255_Bstatic_by_heiye.tar.gz,https://raw.githubusercontent.com/lucktu/n2n/master/Linux/n2n_v3_linux_x64_v3.1.1_r1255_static_by_heiye.tar.gz,https://raw.githubusercontent.com/lucktu/n2n/master/Linux/n2n_v3_linux_x86_v3.1.1_r1255_Bstatic_by_heiye.tar.gz,https://raw.githubusercontent.com/lucktu/n2n/master/Linux/n2n_v3_linux_x86_v3.1.1_r1255_static_by_heiye.tar.gz"
    #         },
    #         ...
    #     ]
    # }
