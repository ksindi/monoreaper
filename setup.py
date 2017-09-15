# -*- coding: utf-8 -*-
"""Distutils setup file, used to install or test 'monoreaper'."""
import textwrap

from setuptools import setup, find_packages

with open('README.md') as f:
    readme = f.read()

setup(
    name='monoreaper',
    description='Create a monorepo by merging multiple git repositories into a master directory',
    long_description=readme,
    packages=find_packages(exclude=['tests', 'examples', 'bootstrap']),
    use_scm_version=True,
    author='Kamil Sindi',
    author_email='kysindi@gmail.com',
    url='https://github.com/ksindi/monoreaper',
    keywords='monorepo git'.split(),
    license='MIT',
    install_requires=[],
    setup_requires=[
        'pytest-runner',
        'setuptools_scm',
        'sphinx_rtd_theme',
    ],
    tests_require=[
        'pytest'
    ],
    include_package_data=True,
    zip_safe=False,
    entry_points={
        'scripts': [
            'monoreaper=monoreaper.sh'
        ]
    },
    classifiers=textwrap.dedent("""
        Development Status :: 4 - Beta
        Intended Audience :: Developers
        License :: OSI Approved :: MIT License
        Environment :: Console
        Programming Language :: Python :: 2
        Programming Language :: Python :: 2.7
        Programming Language :: Python :: 3
        Programming Language :: Python :: 3.4
        Programming Language :: Python :: 3.5
        Programming Language :: Python :: 3.6
        """).strip().splitlines(),
)
