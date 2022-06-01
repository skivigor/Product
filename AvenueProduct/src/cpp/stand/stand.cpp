#include "stand.h"
#include "util/fileloader.h"
#include <QCryptographicHash>
#include <QUrl>

#include <QDebug>
#include "assert.h"

namespace
{
const quint8  fnCode       = 0x78;
const quint8  fnGetHwType   = 0x01;
const quint8  fnGetSwType   = 0x02;

const QString strGetHw("Stand/GetHwType");
const QString strGetSw("Stand/GetSwType");

const quint8  retryNum = 3;

const QString strUndef("Undefined");
}


namespace stand
{

Stand::Stand(QObject *parent)
    : m_inited(false),
      m_hwType(strUndef),
      m_swType(strUndef)
{
    Q_UNUSED(parent)
    QObject::connect(&m_model, &FwModel::checked, this, &Stand::checked);
    QObject::connect(&m_model, &FwModel::loaded, this, &Stand::loaded);
    QObject::connect(&m_model, &FwModel::error, this, &Stand::error);
    qDebug() << "Stand::Stand: ctor: " << &m_model;
}

Stand::~Stand()
{
    qDebug() << "Stand::~Stand: dtor";
}

//-----------------------------------------------------------------

void Stand::onRcvData(const QByteArray &data)
{
    qDebug() << "Stand::onRcvData: data: " << data.toHex();

    if (data.isEmpty()) return;
    if (data.at(0) != data.size()) return;

    if (data.at(1) == fnCode && data.at(2) == fnGetHwType)
    {
        QByteArray ba = data.mid(3);
        m_hwType = QString(ba);
        qDebug() << "Stand::onRcvData: HW type: " << m_hwType;
        emit hwTypeChanged();
    }

    if (data.at(1) == fnCode && data.at(2) == fnGetSwType)
    {
        QByteArray ba = data.mid(3);
        m_swType = QString(ba);
        qDebug() << "Stand::onRcvData: SW type: " << m_swType;
        emit swTypeChanged();
    }

    if (m_hwType != strUndef && m_swType != strUndef)
    {
        m_inited = true;
        emit initChanged();
    }
}

//-----------------------------------------------------------------

void Stand::setSerialLink(trans::SerialClient *ptr)
{
    qDebug() << "Stand::setSerialLink: ptr: " << ptr;
    m_queue.setLink(ptr);
    m_model.setLink(ptr);
}

//-----------------------------------------------------------------

void Stand::init()
{
    qDebug() << "Stand::init";
    QByteArray ba;
    QByteArray resp;
    QSharedPointer<StandCmd> ptr;
    typedef QPair<ICmdOwner*, QSharedPointer<StandCmd>> Cmd;
    Cmd cmd;

    // Get HW type
    ba.append(0x03);    // len
    ba.append(fnCode);    // func
    ba.append(fnGetHwType);    //
    resp.append(fnCode);
    resp.append(fnGetHwType);
    ptr = QSharedPointer<StandCmd>(new StandCmd(fnCode, ba, resp, retryNum, strGetHw));
    assert(!ptr.isNull());
    cmd = Cmd(this, ptr);
    m_queue.add(cmd);

    ba.clear();
    resp.clear();
    ptr.clear();

    // Get SW type
    ba.append(0x03);    // len
    ba.append(fnCode);    // func
    ba.append(fnGetSwType);    //
    resp.append(fnCode);
    resp.append(fnGetSwType);
    ptr = QSharedPointer<StandCmd>(new StandCmd(fnCode, ba, resp, retryNum, strGetSw));
    assert(!ptr.isNull());
    cmd = Cmd(this, ptr);
    m_queue.add(cmd);

    // Execute
    m_queue.execute();
}

//-----------------------------------------------------------------

void Stand::selectFw(const QString &cfgPath, const QString &fwPath)
{
    if (!m_inited) return;
    m_model.reload(cfgPath, fwPath);
}

//-----------------------------------------------------------------

bool Stand::addFirmwareToModel(const QJsonObject &cfg, const QString &fileName, const QString &md5AsBase64, const QString &fwAsBase64)
{
    qDebug() << "Stand::addFirmwareToModel: name: " << fileName;
    qDebug() << "Stand::addFirmwareToModel: cfg: " << cfg;
    QByteArray rmd5 = QByteArray::fromBase64(md5AsBase64.toLocal8Bit());
    qDebug() << "Stand::addFirmwareToModel: Received MD5: " << rmd5.toHex();

    QByteArray data = QByteArray::fromBase64(fwAsBase64.toLocal8Bit());
    QByteArray cmd5 = QCryptographicHash::hash(data, QCryptographicHash::Md5);
    qDebug() << "Stand::addFirmwareToModel: Calculated MD5: " << cmd5.toHex();
    if (rmd5 != cmd5) return false;

    m_model.addItem(cfg, fileName, data);
    return true;
}

//-----------------------------------------------------------------

bool Stand::addFirmwareToModel(const QJsonObject &cfg, const QString &path)
{
    qDebug() << "Stand::addFirmwareToModel: path: " << path;
    qDebug() << "Stand::addFirmwareToModel: path: " << QUrl(path).toLocalFile();
    QStringList list = path.split("/");
    QString name = "__" + list.last();
    qDebug() << "Stand::addFirmwareToModel: name: " << name;

    util::FileLoader &ldr = util::FileLoader::instance();
    QByteArray fw = ldr.getFileAsBin(QUrl(path).toLocalFile());
    if (fw.isEmpty()) return false;

    QByteArray md5 = QCryptographicHash::hash(fw, QCryptographicHash::Md5);
    qDebug() << "Stand::addFirmwareToModel: md5: " << md5.toHex();

    m_model.addItem(cfg, name, fw);
    return true;
}

//-----------------------------------------------------------------

//void Stand::clearModel()
//{
//    m_model.clear();
//}

//-----------------------------------------------------------------

void Stand::checkFw()
{
    qDebug() << "Stand::checkFw";
    if (!m_inited) return;
    m_model.checkFw();
}

//-----------------------------------------------------------------

void Stand::loadFw()
{
    qDebug() << "Stand::loadFw";
    if (!m_inited) return;
    m_model.loadFw();
}

//-----------------------------------------------------------------

void Stand::resetCheckStatus()
{
    qDebug() << "Stand::resetCheckFw";
    if (!m_inited) return;
    m_model.resetCheckStatus();
}

//-----------------------------------------------------------------

void Stand::resetLoadStatus()
{
    qDebug() << "Stand::resetLoadFw";
    if (!m_inited) return;
    m_model.resetLoadStatus();
}

//-----------------------------------------------------------------

QByteArray Stand::getData() const
{
    QByteArray ba;
    for (int i = 0; i < 256; ++i) ba.append(static_cast<char>(i));

    return ba;
}

//-----------------------------------------------------------------

std::vector<int> Stand::getDataVec() const
{
    QByteArray ba;
    for (int i = 0; i < 256; ++i) ba.append(static_cast<char>(i));

    std::vector<int> vec(ba.begin(), ba.end());
    return vec;
}

//-----------------------------------------------------------------

}    // namespace stand

