#include "serialport.h"
#include <QDebug>

SerialPort::SerialPort(QObject *parent) : QObject(parent)
{
    QObject::connect(this, SIGNAL(nameChanged(QString)), this, SLOT(reconnect()));
    QObject::connect(this, SIGNAL(baudRateChanged(int)), this, SLOT(reconnect()));
}

SerialPort::~SerialPort()
{

}

void SerialPort::reconnect()
{
    if (m_name.isEmpty() || m_baudRate == 0)
    {
        qDebug() << "empty";
        return;
    }

    if (m_serialPort == 0) {
        m_serialPort = new QSerialPort();
    }

    qDebug() << "m_baudRate = " << m_baudRate;
    m_serialPort->setPortName(m_name);
    m_serialPort->setBaudRate(m_baudRate);

    if (!m_serialPort->open(QIODevice::ReadOnly)) {
        m_serialPort->deleteLater();
        qDebug() << QObject::tr("Failed to open port %1, error: %2").arg(m_name).arg(m_serialPort->errorString());
        return;
    }

    connect(m_serialPort, SIGNAL(readyRead()), SLOT(handleReadyRead()));
    connect(m_serialPort, SIGNAL(error(QSerialPort::SerialPortError)), SLOT(handleError(QSerialPort::SerialPortError)));
}

void SerialPort::handleReadyRead()
{
    QString data = QString(m_serialPort->readAll());
    data = data.trimmed();
    emit messageReceived(data);

    m_serialPort->flush();
}

void SerialPort::handleError(QSerialPort::SerialPortError error)
{
    qDebug() << Q_FUNC_INFO << error;
}

