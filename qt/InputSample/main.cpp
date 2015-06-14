#include <QApplication>
#include <QQmlApplicationEngine>
#include "serialportreader.h"

#include <QtSerialPort/QSerialPort>
#include <QDebug>
#include "serialport.h"
#include <QtQml>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterType<SerialPort>("com.sample", 1, 0, "SerialPort");
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));


//    QSerialPort serialPort;
//    QString serialPortName = "/dev/cu.usbserial-FTGQCF2N";
//    serialPort.setPortName(serialPortName);
//    serialPort.setBaudRate(QSerialPort::Baud115200);

//    if (!serialPort.open(QIODevice::ReadOnly)) {
//        qDebug() << QObject::tr("Failed to open port %1, error: %2").arg(serialPortName).arg(serialPort.errorString()) << endl;
//        return 1;
//    }

//    SerialPortReader serialPortReader(&serialPort, &app, &engine);


    return app.exec();
}
