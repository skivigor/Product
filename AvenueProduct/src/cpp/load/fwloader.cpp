#include "fwloader.h"


#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonParseError>

#include <QDebug>
#include "assert.h"

namespace
{

QJsonDocument openJsonFile(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
    {
        file.close();
        qWarning() << "AvBuilder::openJsonFile: Can not open " << path;
        return QJsonDocument();
    }
    QString str = file.readAll();
    file.close();

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(str.toUtf8(), &err);
    if (err.error != QJsonParseError::NoError)
    {
        qWarning() << "AvBuilder::openJsonFile: ERROR at " << path;
        return QJsonDocument();
    }

    return doc;
}

}    // namespace


namespace load
{

FwLoader::FwLoader(const QString &cfgPath, const QString &fwPath, QObject *parent)
    : m_pClient(nullptr),
      m_cfgPath(cfgPath),
      m_fwPath(fwPath),
      m_allBlocksNum(0)
{
    Q_UNUSED(parent);
    reload();
    qDebug() << "FwLoader::FwLoader: ctor";
}

FwLoader::~FwLoader()
{
    //
}

//-----------------------------------------------------------------

void FwLoader::reload()
{
    QJsonDocument doc = openJsonFile(m_cfgPath);
    QJsonObject jObj = doc.object();
    assert(jObj["firmware"].isArray());
    assert(doc.object()["firmware"].isArray());
    QJsonArray jArr = jObj.value("firmware").toArray();

    for (int i = 0; i < jArr.size(); ++i)
    {
        QJsonObject obj = jArr.at(i).toObject();
        qDebug() << "FwLoader::FwLoader: Cfg obj: " << obj;

        QString descr = obj.value("descr").toString();
        QString path = m_fwPath + "/" + obj.value("bin").toString();
        quint8 cmdSetVer = obj.value("cmdSetVer").toString().toInt(nullptr, 16);
        quint8 cmdGetVer = obj.value("cmdGetVer").toString().toInt(nullptr, 16);
        quint8 cmdWrite = obj.value("cmdWrite").toString().toInt(nullptr, 16);
        quint8 cmdCheck = obj.value("cmdCheck").toString().toInt(nullptr, 16);

        FirmwareCmdProfile prof;
        prof.CmdSetVer = cmdSetVer;
        prof.CmdGetVer = cmdGetVer;
        prof.CmdWriteBlock = cmdWrite;
        prof.CmdCheck = cmdCheck;

        QSharedPointer<Firmware> ptr(QSharedPointer<Firmware>(new Firmware(descr, path, prof, 128)));
        assert(!ptr.isNull());
        m_listFirm.append(ptr);

//        qDebug() << "FwLoader::FwLoader: Descr: " << descr;
//        qDebug() << "FwLoader::FwLoader: Path: " << path;
//        qDebug() << "FwLoader::FwLoader: cmdSetVer: " << hex << cmdSetVer;
    }
}

//-----------------------------------------------------------------

void FwLoader::onRcvData(QByteArray data)
{
//    qDebug() << "FwLoader::onRcvData: " << data.toHex();

    if (data.isEmpty() || m_cmd.isNull()) return;
    m_cmd->rcvData(data);
}

//-----------------------------------------------------------------

void FwLoader::processQueue()
{
//    qDebug() << "FwLoader::processQueue : " << m_queue.size();
    if (m_queue.isEmpty())
    {
        m_cmd.clear();
        return;
    }
    if (!m_cmd.isNull()) return;

    m_cmd = m_queue.dequeue();
    QObject::connect(m_cmd.data(), SIGNAL(sendData(QByteArray)), this, SLOT(onCmdSendData(QByteArray)));
    QObject::connect(m_cmd.data(), SIGNAL(executed()), this, SLOT(onExecuted()));
    QObject::connect(m_cmd.data(), SIGNAL(execError(StandCmd::ErrorType)), this, SLOT(onExecError(StandCmd::ErrorType)));
    m_cmd->execute();
}

//-----------------------------------------------------------------

void FwLoader::onExecuted()
{
    QByteArray data = m_cmd->getResponse();
    qDebug() << "FwLoader::onExecuted: " << data.toHex();

    m_cmd->disconnect();
    m_cmd.clear();
    processQueue();
}

//-----------------------------------------------------------------

void FwLoader::onExecError(StandCmd::ErrorType type)
{
    qDebug() << "FwLoader::onExecError: queue: " << m_queue.size();

    if (type == StandCmd::ErrorType::TYPE_TIMEOUT)
    {
        qDebug() << "> ERROR!!! " << m_cmd->getDescription() << " : timeout\n";
        m_queue.clear();
        m_cmd.clear();

        qDebug() << "FwLoader::onExecError: clear queue: " << m_queue.size();
        return;
    }

    if (type == StandCmd::ErrorType::TYPE_RESP)
    {
        QByteArray data = m_cmd->getResponse();
        QString descr = m_cmd->getDescription();
        m_cmd->disconnect();
        m_cmd.clear();

        qDebug() << "> ERROR!!! " << descr << ": Invalid resp: " << data.toHex().toUpper();

        processQueue();
        return;
    }

}

//-----------------------------------------------------------------

void FwLoader::onCmdSendData(const QByteArray &data)
{
    if (data.isEmpty()) return;
    m_pClient->sendData(data);
}

//-----------------------------------------------------------------

void FwLoader::setSerialClient(trans::SerialClient *ptr)
{
    qDebug() << "FwLoader::setSerialClient: " << ptr;
    m_pClient = ptr;
}

//-----------------------------------------------------------------

bool FwLoader::check()
{
    qDebug() << "FwLoader::check";
    if (!m_pClient) return false;
    QObject::connect(m_pClient, SIGNAL(rcvData(QByteArray)), SLOT(onRcvData(QByteArray)));

    QByteArray ba;
    QByteArray resp;
    QSharedPointer<StandCmd> ptr;

    for (int i = 0; i < 50; ++i)
    {
        ba.clear();
        resp.clear();
        ptr.clear();

        // Test cmd
        ba.append(0x03);    // len
        ba.append(0x78);    // func
        ba.append(0x01);    //
        resp.append(0x78);
        resp.append(0x01);
        ptr = QSharedPointer<StandCmd>(new StandCmd(0x78, ba, resp, 3, "Get HW"));
        assert(!ptr.isNull());
        m_queue.enqueue(ptr);

        ba.clear();
        resp.clear();
        ptr.clear();

        // Test cmd
        ba.append(0x03);    // len
        ba.append(0x78);    // func
        ba.append(0x02);    //
        resp.append(0x78);
        resp.append(0x02);
        ptr = QSharedPointer<StandCmd>(new StandCmd(0x78, ba, resp, 3, "Get SW"));
        assert(!ptr.isNull());
        m_queue.enqueue(ptr);
    }

    processQueue();
    return true;
}

//-----------------------------------------------------------------

void FwLoader::loadToStand()
{
    qDebug() << "FwLoader::loadToStand";

}

//-----------------------------------------------------------------

void FwLoader::upload()
{
    qDebug() << "FwLoader::upload";
}

//-----------------------------------------------------------------

}    // namespace load

