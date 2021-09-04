# This VMFUNC-triggering-VMI hypervisor is based on Xen.

# Functionalities

## 1. for guest user. 
If a guest user would like to run a susceptible app, but has no idea whether the app is a malware-ish, he/she could use the VMFUNC interface to ask hypervisor to do the VMI scanning for her.
## 2. for cloud provider. 
The cloud provider can use it to monitoring a guest-VM's behavior.

# Features

## 1. fast. 
Very fast. Firstly, VMFUNC is way to faster than hypercall. Secondly, Dom0's VMI program can scan the guest's memory without pausing the guest-VM.
## 2. providing an easy-to-use interface for guest-users. (VMI-as-a-Service)

# It consists of three parts

## 1. VMFUNC perception module
VMFUNC overloading.
DomID and eptp index calculation.
## 2. Params recording module
Event logging.
## 3. VMI triggering module
Params parsing.

# Usage

## Install the modified Xen 
Please check the `Xen-4.6.0/xen` folder.

## Install the modified Xentools
Please check the `Xen-4.6.0/tools`

## Install libvmi

### The three steps above can be found on the homepages of Xen and LibVMI.

## Creating a HVM guest
Please also refer to Xen homepage.
In each guest, users had better add the two following lines in original config files:

altp2mhvm = 1
shadow_memory = 16

## Create alternative EPTs for the target VM
Please see the code in `hvm_altp2m_prepare_for_vmfunc_test` folder.

## Insert VMFUNC instructions in the suspicious process on the target VM
Please see the code in `exec_vmfunc`.

## Make a VMI example in Dom0
Our team have made two programs, cMonitor and CAPT.
Please find our paper 'cMonitor: VMI-Based Fine-Grained Monitoring Mechanism in Cloud' and 'CAPT: Context-Aware Provenance Tracing for Attack Forensics'.

## Insert the VMI example in tools/xentrace/xentrace.c

## Switch on
Please see the code in `switch on`.

## Start Xentrace
Example command: xentrace -D -e 0X00082030 tracelog.dat

Here '0x00082030' is the eventmask for VMFUNC, which is built-in code in our modified Xen version.

## Now you can use the VMI program to check the output without pause the target VM!
