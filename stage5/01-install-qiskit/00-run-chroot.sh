#!/bin/bash -e

# Clone the Git repository
echo "Starting qiskit Installation"
export CLONE_DIR="/tmp/${REPO}"

if [ ! -d "${CLONE_DIR}" ]; then
    git clone --branch ${GIT_BRANCH} ${GIT_REPO} ${CLONE_DIR}
fi

chmod 755 ${CLONE_DIR}

#wget ${RASP_WGET} -O raspi-config
# Copy the raspi-config file to the desired locations
# cp  raspi-config  /usr/bin/raspi-config
# cp  raspi-config  /etc/init.d/raspi-config # why is is it copied here as well? This can stay the standard unmodified raspi-config

echo "FIRST_USER_NAME    : ${FIRST_USER_NAME}"
[ ! -d /home/${FIRST_USER_NAME}/.local/bin ] && mkdir -p /home/${FIRST_USER_NAME}/.local/bin
[ ! -d /home/${FIRST_USER_NAME}/${RQB2_CONFDIR} ] && mkdir -p /home/${FIRST_USER_NAME}/${RQB2_CONFDIR}
[ ! -d /usr/config ] && mkdir -p /usr/config
[ ! -d /usr/venv ] && mkdir -p /usr/venv

chmod -R  755  ${CLONE_DIR}/bin
chmod -R  755  ${CLONE_DIR}/config

cp ${CLONE_DIR}/bin/* /home/${FIRST_USER_NAME}/.local/bin/
cp -r ${CLONE_DIR}/config/* /home/${FIRST_USER_NAME}/${RQB2_CONFDIR}/

cp ${CLONE_DIR}/bin/* /usr/bin
cp -r ${CLONE_DIR}/config/* /usr/config

chmod 755 /home/${FIRST_USER_NAME}/.local/bin 
chmod 755 /home/${FIRST_USER_NAME}/${RQB2_CONFDIR}

# apply RQB2 patch to /usr/bin/raspi-config at boot time
(crontab -l 2>/dev/null; echo "@reboot /usr/bin/rq_patch_raspiconfig.sh") | crontab -

# Clean up the temporary clone directory if needed
# Install Qiskit using pip
echo "install qiskit for ${FIRST_USER_NAME} user"
mkdir -p /home/${FIRST_USER_NAME}/$REPO/venv/$STD_VENV

python3 -m venv /home/${FIRST_USER_NAME}/$REPO/venv/$STD_VENV --system-site-packages
source /home/${FIRST_USER_NAME}/$REPO/venv/$STD_VENV/bin/activate
.  /home/"${FIRST_USER_NAME}"/.local/bin/rq_install_Qiskit_latest.sh
deactivate

#cp -r /home/${FIRST_USER_NAME}/.local  "${ROOTFS_DIR}"/home/${FIRST_USER_NAME}/
#cp  -r /home/${FIRST_USER_NAME}/$REPO "${ROOTFS_DIR}"/home/${FIRST_USER_NAME}/
cp  -r /home/${FIRST_USER_NAME}/$REPO  /usr/venv
export LINE=". /usr/config/setup_qiskit_env.sh"
echo "$LINE" >> /etc/skel/.bashrc
echo "$LINE" >> /home/${FIRST_USER_NAME}/.bashrc
echo "install qiskit end for ${FIRST_USER_NAME}"
rm -rf $CLONE_DIR
echo "End  qiskit Installation"
