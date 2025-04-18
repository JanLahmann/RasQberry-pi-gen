#!/bin/bash -e

# Clone the Git repository
echo "Starting qiskit Installation"
export CLONE_DIR="/tmp/${REPO}"

if [ ! -d "${CLONE_DIR}" ]; then
    git clone --branch ${GIT_BRANCH} ${GIT_REPO} ${CLONE_DIR}
fi

chmod 755 ${CLONE_DIR}

wget ${RASP_WGET} -O raspi-config
# Copy the raspi-config file to the desired locations
 cp  raspi-config  ${ROOTFS_DIR}/usr/bin/raspi-config
 cp  raspi-config  ${ROOTFS_DIR}/etc/init.d/raspi-config

echo "FIRST_USER_NAME    : ${FIRST_USER_NAME}"
[ ! -d /home/${FIRST_USER_NAME}/.local/bin ] && mkdir -p /home/${FIRST_USER_NAME}/.local/bin
[ ! -d /home/${FIRST_USER_NAME}/${RQB2_CONFDIR} ] && mkdir -p /home/${FIRST_USER_NAME}/${RQB2_CONFDIR}
[ ! -d ${ROOTFS_DIR}/usr/config ] && mkdir -p ${ROOTFS_DIR}/usr/config
[ ! -d ${ROOTFS_DIR}/usr/venv ] && mkdir -p ${ROOTFS_DIR}/usr/venv

chmod -R  755  ${CLONE_DIR}/bin
chmod -R  755  ${CLONE_DIR}/config

cp ${CLONE_DIR}/bin/* /home/${FIRST_USER_NAME}/.local/bin/
cp -r ${CLONE_DIR}/config/* /home/${FIRST_USER_NAME}/${RQB2_CONFDIR}/

cp ${CLONE_DIR}/bin/* ${ROOTFS_DIR}/usr/bin
cp -r ${CLONE_DIR}/config/* ${ROOTFS_DIR}/usr/config

chmod 755 /home/${FIRST_USER_NAME}/.local/bin 
chmod 755 /home/${FIRST_USER_NAME}/${RQB2_CONFDIR}

# Clean up the temporary clone directory if needed
# Install Qiskit using pip
echo "install qiskit for ${FIRST_USER_NAME} user"
mkdir -p /home/${FIRST_USER_NAME}/$REPO/venv/$STD_VENV

echo $PATH
ls /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

python3 -m venv /home/${FIRST_USER_NAME}/$REPO/venv/$STD_VENV --system-site-packages
source /home/${FIRST_USER_NAME}/$REPO/venv/$STD_VENV/bin/activate
.  /home/"${FIRST_USER_NAME}"/.local/bin/rq_install_Qiskit_latest.sh
deactivate

cp -r /home/${FIRST_USER_NAME}/.local  "${ROOTFS_DIR}"/home/${FIRST_USER_NAME}/
cp  -r /home/${FIRST_USER_NAME}/$REPO "${ROOTFS_DIR}"/home/${FIRST_USER_NAME}/
cp  -r /home/${FIRST_USER_NAME}/$REPO  "${ROOTFS_DIR}"/usr/venv
export LINE=". /usr/config/setup_qiskit_env.sh"
echo "$LINE" >> ${ROOTFS_DIR}/etc/skel/.bashrc
echo "$LINE" >> ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.bashrc
echo "install qiskit end for ${FIRST_USER_NAME}"
rm -rf $CLONE_DIR
echo "End  qiskit Installation"
