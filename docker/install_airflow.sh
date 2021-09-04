#!/bin/bash
set -euo pipefail

# These are picked up from the Docker ENV.
AIRFLOW_DIR=${INSTALL_DIR}/${PARCEL_NAME}
PYVER=$(echo "$PYTHON_VERSION" | awk -F. '{print $1"."$2}')
PYMAJVER=$(echo "$PYTHON_VERSION" | awk -F. '{print $1}')

PATH="${AIRFLOW_DIR}/bin:${PATH}"
PIPOPTS=""

pip $PIPOPTS install apache-airflow=="${AIRFLOW_VERSION}"

echo "*** Installing Airflow plugins..."
echo "** Installing Airflow[celery]."
pip $PIPOPTS install 'apache-airflow[celery]'
echo "** Installing Airflow[mysql]."
pip $PIPOPTS install 'apache-airflow[mysql]'
echo "** Installing Airflow[postgres]."
pip $PIPOPTS install 'apache-airflow[postgres]'
echo "** Installing Airflow[kerberos]."
pip $PIPOPTS install 'apache-airflow[kerberos]'
echo "** Installing Airflow[crypto]."
pip $PIPOPTS install 'apache-airflow[crypto]'
echo "** Installing Airflow[hive]."
pip $PIPOPTS install 'apache-airflow[hive]'
echo "** Installing Airflow[password]."
pip $PIPOPTS install 'apache-airflow[password]'
echo "** Installing Airflow[rabbitmq]."
pip $PIPOPTS install 'apache-airflow[rabbitmq]'

echo "*** Installing airflow..."
mv "${AIRFLOW_DIR}/bin/airflow" "${AIRFLOW_DIR}/bin/.airflow"

echo "*** Installing airflow shell wrapper..."
install -m 0755 -o root -g root /dev/null "${AIRFLOW_DIR}/bin/airflow"
cat <<EOF >"${AIRFLOW_DIR}/bin/airflow"
#!/bin/bash
export PATH=${AIRFLOW_DIR}/bin:\$PATH
export PYTHONHOME=${AIRFLOW_DIR}
export PYTHONPATH=${AIRFLOW_DIR}/lib/python${PYVER}

# AIRFLOW_HOME & AIRFLOW_CONFIG
if [ -f /etc/airflow/conf/airflow-env.sh ]; then
  . /etc/airflow/conf/airflow-env.sh
else
  export AIRFLOW_HOME=/var/lib/airflow
  export AIRFLOW_CONFIG=/etc/airflow/conf/airflow.cfg
fi

exec ${AIRFLOW_DIR}/bin/.airflow \$@
EOF

