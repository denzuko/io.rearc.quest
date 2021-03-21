#! /usr/bin/env python3
#-*- coding: utf-8 -*-

from os import remove
from os.path import basename, dirname, realpath, exists, isdir, isfile
from shutil import rmtree
#from dotenv import load_dotenv
from invoke import task

#def load_env(path=f'{PWD}/.env'):
#    return load_dotenv(dotenv_path=path)

def pwd():
    return dirname(realpath(__file__))

@task(default=True)
def docker_image(ctx):
    tag = basename(pwd())
#    env = load_env()
    ctx.run(f"docker image build -t {tag}:latest .")

@task
def tf_init(ctx):
    #env = load_env()
    ctx.run("terraform init")

@task(pre=[tf_init])
def tf_plan(ctx):
    #env = load_env()
    ctx.run("terraform plan")

@task(pre=[docker_image,tf_plan])
def deploy(ctx, tag='ghcr.io/denzuko/clients/io.rearc.quest:latest'):
    #env = load_env()
    ctx.run(f"docker push ${tag}")
    ctx.run("terraform apply")

@task
def clean(ctx):
    for x in [
        ".terraform",
        ".terraform.lock.hcl",
        "infrastructure/.terraform",
        "src/node_modules"
    ]:
        if (exists(x) and isdir(x)):
            rmtree(x)

        if (exists(x) and isfile(x)):
            remove(x)
