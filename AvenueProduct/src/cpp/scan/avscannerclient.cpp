#include "avscannerclient.h"
#include <QCoreApplication>

#include <QDebug>

namespace
{
const QString ScanStateOk("scanstate: ok");
const QString ScanStateError("scanstate: error");
const QString ScanData("scandata:");
}    // namespace


namespace scan
{

AvScannerClient::AvScannerClient(QObject *parent)
    : m_proc(nullptr),
      m_data(""),
      m_openned(false)
{
    Q_UNUSED(parent)

//    m_proc.setProcessChannelMode(QProcess::MergedChannels);

//    QObject::connect(&m_proc, &QProcess::started, this, &AvScannerClient::onStarted);
//    QObject::connect(&m_proc, &QProcess::readyReadStandardOutput, this, &AvScannerClient::onReadyReadStandardOutput);
//    QObject::connect(&m_proc, &QProcess::errorOccurred, this, &AvScannerClient::onErrorOccurred);
//    QObject::connect(&m_proc , SIGNAL(finished(int,QProcess::ExitStatus)), this, SLOT(onFinished(int, QProcess::ExitStatus)));
}

AvScannerClient::~AvScannerClient()
{
    if (m_proc == nullptr) return;

    m_proc->kill();
    m_proc->disconnect();
    delete m_proc;
}

//-----------------------------------------------------------------

void AvScannerClient::onStarted()
{
    qDebug() << "AvScannerClient::onStarted";
    clearData();

    m_openned = true;
    opennedChanged();
}

//-----------------------------------------------------------------

void AvScannerClient::onReadyReadStandardOutput()
{
    m_data = m_proc->readAllStandardOutput();
    qDebug() << "AvScannerClient::onReadyReadStandardOutput: " << m_data;

    if (m_data.contains(ScanStateError)) close();
    if (m_data.contains(ScanData)) emit dataChanged();
}

//-----------------------------------------------------------------

void AvScannerClient::onErrorOccurred(QProcess::ProcessError error)
{
    Q_UNUSED(error)
    qDebug() << "AvScannerClient::onErrorOccurred: " << m_proc->errorString();
}

//-----------------------------------------------------------------

void AvScannerClient::onFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitStatus)
    qDebug() << "AvScannerClient::onFinished: " << exitCode;

    m_proc->disconnect();
    delete m_proc;
    m_proc = nullptr;

    m_openned = false;
    opennedChanged();
}

//-----------------------------------------------------------------

void AvScannerClient::open()
{
    QString path = QCoreApplication::applicationDirPath() + "/AvScanner";
    QString prog = path;  //"AvScanner";
    QStringList args;
    args << "192.168.0.1";

    m_proc = new QProcess();
    if (m_proc == nullptr) return;

    m_proc->setProcessChannelMode(QProcess::MergedChannels);

    QObject::connect(m_proc, &QProcess::started, this, &AvScannerClient::onStarted);
    QObject::connect(m_proc, &QProcess::readyReadStandardOutput, this, &AvScannerClient::onReadyReadStandardOutput);
    QObject::connect(m_proc, &QProcess::errorOccurred, this, &AvScannerClient::onErrorOccurred);
    QObject::connect(m_proc , SIGNAL(finished(int,QProcess::ExitStatus)), this, SLOT(onFinished(int, QProcess::ExitStatus)));


    m_proc->start(prog, args);
}

//-----------------------------------------------------------------

QString AvScannerClient::getData()
{
    QString scan = m_data;
    clearData();
    return scan;
}

//-----------------------------------------------------------------

void AvScannerClient::clearData()
{
    m_data = "";
    emit dataChanged();
}

//-----------------------------------------------------------------

void AvScannerClient::close()
{
    clearData();
    if (m_proc == nullptr) return;

//    m_proc->terminate();
    m_proc->kill();
}

//-----------------------------------------------------------------

}    // namespace scan

