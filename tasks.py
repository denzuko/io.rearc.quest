#! /usr/bin/env python3
#-*- coding: utf-8 -*-

from os import remove
from os.path import basename, dirname, realpath, exists, isdir, isfile
from shutil import rmtree
#from dotenv import load_dotenv
from invoke import task, Collection, call

#def load_env(path=f'{PWD}/.env'):
#    return load_dotenv(dotenv_path=path)

def pwd():
    return dirname(realpath(__file__))

@task
def build_image(ctx, tag='ghcr.io/denzuko/clients/io.rearc.quest:latest'):
#    env = load_env()
    ctx.run(f"docker image build -t {tag} .")
    ctx.run(f"docker push {tag}")

@task
def init(ctx):
    #env = load_env()
    ctx.run("terraform init")

@task(pre=[init])
def plan(ctx, destroy=False):
    #env = load_env()
    ctx.run(" ".join([
        "terraform plan -out=plan.tfplan",
        "-destroy" if destroy else ""
        ]))

@task
def fmt(ctx):
#    env = load_env()
    ctx.run("terraform fmt -diff -recursive")

@task(pre=[init, fmt])
def validate(ctx):
#    env = load_env()
    ctx.run("terraform validate .")

@task(pre=[plan])
def apply(ctx):
    ctx.run("terraform apply plan.tfplan")

@task(pre=[call(plan, destroy=True)], post=[apply])
def destroy(ctx):
    pass

@task(pre=[destroy])
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

@task(pre=[build_image,apply])
def deploy(ctx):
    pass

@task(default=True)
def help(ctx):
    ctx.run('invoke --list')

ns = Collection(clean, deploy, help)
ns.add_collection(Collection('docker', build_image))
ns.add_collection(Collection('terraform', 
    init, plan, fmt, 
    validate, apply, destroy))
