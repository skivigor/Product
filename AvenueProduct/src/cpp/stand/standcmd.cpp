#include "standcmd.h"

#include <QDebug>

namespace
{
const int AlarmTime = 2500;
const int CheckTimeout = 5;
}

namespace stand
{

int StandCmd::m_cmdNum = 0;

StandCmd::StandCmd(quint8 id, const QByteArray &cmd, const QByteArray &validResp, int retry, const QString &descr, QObject *parent)
    : m_id(id),
      m_cmd(cmd),
      m_validResp(validResp),
      m_retryCount(retry),
      m_descr(descr),
      m_waitAns(false)
{
    Q_UNUSED(parent);
    m_cmdNum++;

    m_timer.setSingleShot(true);
    QObject::connect(&m_timer, SIGNAL(timeout()), this, SLOT(onTimeout()), Qt::QueuedConnection);
//    qDebug() << "LightCmd::LightCmd: ctor: " << m_cmdNum;
}

StandCmd::~StandCmd()
{
    m_timer.stop();
    m_cmdNum--;
//    qDebug() << "LightCmd::~LightCmd: dtor: " << m_cmdNum;
}

//-----------------------------------------------------------------

void StandCmd::processing()
{
    if (!m_waitAns)
    {
        m_waitAns = true;
        emit sendData(m_cmd);
        QTimer::singleShot(CheckTimeout, this, SLOT(processing()));
    } else
    {
        if (m_resp.isEmpty())
        {
            QTimer::singleShot(CheckTimeout, this, SLOT(processing()));
            return;
        }

        m_timer.stop();

        if (m_validResp.isEmpty())
        {
            emit executed();
        } else
        {
            if (m_resp.contains(m_validResp))
            {
                emit executed();
            } else
            {
                emit execError(TYPE_RESP);
            }
        }
    }
}

//-----------------------------------------------------------------

void StandCmd::onTimeout()
{
    if (!m_retryCount)
    {
        qDebug() << "LightCmd::onTimeout: emit ERROR";
        emit execError(TYPE_TIMEOUT);
    } else
    {
        qDebug() << "LightCmd::onTimeout: retry: " << m_retryCount;
        m_waitAns = false;
        m_retryCount--;
        execute();
    }
}

//-----------------------------------------------------------------

void StandCmd::execute()
{
    qDebug() << "LightCmd::execute: " << m_cmd.toHex();
    if (m_timer.isActive()) m_timer.stop();
    m_timer.start(AlarmTime);
    processing();
}

//-----------------------------------------------------------------

void StandCmd::rcvData(const QByteArray &data)
{
    m_resp = data;
}

//-----------------------------------------------------------------

}    // namespace stand

