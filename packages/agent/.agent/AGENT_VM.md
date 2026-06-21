# VM 200 Agent Governance — KDE Neon Guest

> **You are running inside a Virtual Machine (VM 200) on a Proxmox host.**
> You are NOT on bare metal. You are NOT on the Proxmox host.
> Never confuse guest-side and host-side operations.

## 1. Architecture Awareness

This machine is a **KDE Neon (Ubuntu-based) VM** running on Proxmox VE.
The physical host is an ASUS TUF Gaming F15 (FX507ZC4) with i5-12500H / 32GB RAM.

- **Virtualization**: QEMU/KVM with PCI passthrough (full Physical Function, NOT SR-IOV)
- **Why hardware looks real**: PCI passthrough exposes physical devices directly to this VM.
  `lspci` will show real Intel/NVIDIA hardware — this does NOT mean you are on bare metal.
- **Host kernel**: `6.14.8-2-pve` (Proxmox) — you will NEVER see this kernel inside the VM
- **Guest kernel**: Ubuntu generic (e.g., `6.14.0-29-generic`) — this is YOUR kernel
- **Host IP**: 10.42.7.2 (not directly accessible from here)
- **Guest IP**: 10.42.7.9 (static, on vmbr1 bridge)

## 2. Kernel Rules

| Rule | Explanation |
|------|-------------|
| **Never recommend installing PVE kernels** | `proxmox-headers-*`, `pve-kernel-*` are host-only packages. They do not belong here. |
| **Never recommend switching to a PVE kernel** | This VM runs Ubuntu generic kernels. That is correct and intentional. |
| **Kernel upgrades are OK** | You may upgrade within Ubuntu generic kernels (e.g., 6.14 → 6.15) if needed. |
| **Kernel pinning is OK** | The VM pins to `6.14.0-29-generic` for stability. Respect the pin. |

## 3. GPU & Driver Rules

### Hardware Map (Guest PCI → Physical Device)

| Guest PCI ID | Device | Physical Hardware | Drives |
|:---|:---|:---|:---|
| `01:00.0` | Intel Iris Xe Graphics `[8086:46a6]` | Physical Intel iGPU | Built-in laptop eDP screen |
| `02:00.0` | NVIDIA RTX 3050 Mobile `[10de:25a2]` | Physical NVIDIA dGPU | HDMI external monitor |
| `03:00.0` | Intel Alder Lake PCH-P Audio `[8086:51c8]` | Physical audio controller | Built-in speakers & mic |
| `00:1b.0` | ICH9 HD Audio `[8086:293e]` | QEMU virtual audio | Virtual audio (noVNC/SPICE) |

### Driver Rules

| Rule | Explanation |
|------|-------------|
| **Do NOT install SR-IOV drivers** | This VM uses full PF passthrough. SR-IOV (`i915-sriov`) is a host-side concept that does not apply here. |
| **Do NOT modify VFIO bindings** | VFIO is a host-side mechanism. This VM does not use VFIO. |
| **i915 driver is correct** | The Intel iGPU uses the standard `i915` kernel module. This is normal. |
| **nvidia proprietary driver is correct** | The NVIDIA GPU uses the proprietary `nvidia` driver. DKMS builds it for the guest kernel. |
| **xe driver is blacklisted** | `/etc/modprobe.d/blacklist-xe.conf` — intentional, do not undo. |

## 4. Known False Positives

These conditions LOOK like errors but are **completely normal** in this passthrough VM:

| What You See | Why It Is Normal |
|:---|:---|
| `i915: VBT not found` in dmesg | Expected — the iGPU VBIOS table is not fully exposed through passthrough. Display works fine regardless. |
| Kernel taint flags from NVIDIA | Standard for proprietary nvidia module. Not a problem. |
| PCI addresses don't match "expected" bare-metal slots | Passthrough remaps PCI topology. Guest addresses (01:00.0, 02:00.0) are QEMU-assigned, not physical. |
| `i915` loads on PCI 01:00.0 instead of 00:02.0 | Normal for passthrough — bare-metal iGPU sits at 00:02.0 but QEMU remaps it. |
| No `nouveau` driver loaded | Intentional — proprietary `nvidia` driver is used instead. |
| `snd_hda_intel` on two different devices | One is real passthrough audio (03:00.0), one is QEMU virtual (00:1b.0). Both are correct. |

## 5. Scope Boundaries

### You CAN Do (Guest-Side)
- Install/remove packages via apt
- Configure display settings (KDE Display Configuration)
- Manage i915 and nvidia drivers (guest kernel modules)
- Edit `/etc/default/grub` and run `update-grub` (guest bootloader)
- Configure network (NetworkManager, static IP 10.42.7.9)
- Manage desktop environment (KDE Plasma, SDDM)
- Install Flatpaks, Snaps, AppImages
- Configure PipeWire/PulseAudio
- Run CUDA/AI workloads on the NVIDIA GPU
- Manage systemd services inside the VM
- Create/edit files in /home/mbs

### You CANNOT Do (Host-Side — Do NOT Attempt)
- Modify the Proxmox host kernel or boot parameters
- Change VFIO/passthrough bindings
- Install SR-IOV or DKMS modules meant for the host
- Access `/etc/pve/` or Proxmox cluster configuration
- Sleep/hibernate the physical laptop (only VM shutdown/reboot)
- Modify IOMMU groups or PCI device assignments
- Access other VMs or containers on the host

## 6. Communicating Host-Side Issues

If you identify a problem that requires host-side intervention:

1. **Do NOT attempt to fix it from inside the VM**
2. Write a report to `/home/mbs/HostReports/` with:
   - Filename: `YYYY-MM-DD_description.md`
   - What you observed (symptoms, logs, error messages)
   - What you believe the root cause is
   - What host-side action you recommend
3. Inform the user that the issue requires host-side attention

## 7. Display Configuration

- **SDDM (login screen)**: X11-based, uses `/etc/X11/xorg.conf.d/10-gpu-priority.conf`
- **User session**: KWin Wayland (ignores xorg.conf, uses DRM/KMS directly)
- **Primary display**: Intel iGPU → eDP laptop panel
- **Secondary display**: NVIDIA → HDMI external
- **Virtual display**: virtio-gpu via noVNC (accessible as Virtual-1 in KDE Display Settings)

## 8. Network

- **IP**: 10.42.7.9 (static via NetworkManager)
- **Gateway**: 10.42.7.1 (OPNsense VM 100)
- **DNS**: Managed by OPNsense
- **SSH**: Enabled on port 22

## 9. System Services to Preserve

- `sddm` — display manager
- `NetworkManager` — network (do NOT switch to systemd-networkd)
- `pipewire` / `wireplumber` — audio stack
- `qemu-guest-agent` — host communication (critical for `qm guest exec`)
- `ssh` — remote access

---
*This document is the single source of truth for AI agents running inside VM 200.*
*Last updated: 2026-03-15*
