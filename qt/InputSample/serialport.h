#ifndef SERIALPORT_H
#define SERIALPORT_H

#include <QObject>
#include <QtSerialPort/QSerialPort>

class SerialPort : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(int baudRate READ baudRate WRITE setBaudRate NOTIFY baudRateChanged)
public:
    explicit SerialPort(QObject *parent = 0);
    ~SerialPort();

    QString name() const
    {
        return m_name;
    }

    int baudRate() const
    {
        return m_baudRate;
    }
private slots:
    void reconnect();
    void handleReadyRead();
    void handleError(QSerialPort::SerialPortError error);
signals:

    void nameChanged(QString arg);
    void baudRateChanged(int arg);

    void messageReceived(QString message);

public slots:
    void setName(QString arg)
    {
        if (m_name == arg)
            return;

        m_name = arg;
        emit nameChanged(arg);
    }
    void setBaudRate(int arg)
    {
        if (m_baudRate == arg)
            return;

        m_baudRate = arg;
        emit baudRateChanged(arg);
    }

private:
    QString m_name;
    int m_baudRate = 0;
    QSerialPort *m_serialPort = 0;
};
#endif // SERIALPORT_H
