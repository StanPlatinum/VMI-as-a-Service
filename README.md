# This VMFUNC-triggering-VMI hypervisor is based on Xen.

# Functionalities:
## 1. for guest user. 
If a guest user would like to run a susceptible app, but has no idea whether the app is a malware-ish, he/she could use the VMFUNC interface to ask hypervisor to do the VMI scanning for him/her.
## 2. for cloud provider. 
The cloud provider can use it as an instumentation tools to monitoring a guest-VM's behavior.

# Features:
## 1. fast. 
Very fast. Firstly, VMFUNC is way to faster than hypercall. Secondly, Dom0's VMI program can scan the guest's memory without pausing the guest-VM.
## 2. providing an easy-to-use interface for guest-users. (VMI-as-a-Service)

# It consists of three parts:
## 1. VMFUNC perception module
    ### VMFUNC overloading.
    ### DomID and eptp index calculation.
## 2. Params recording module
    ### Event logging.
## 3. VMI triggering module
    ### Params parsing.