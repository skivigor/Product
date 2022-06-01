#include "cmdqueue.h"

#include <QDebug>
#include "assert.h"

namespace stand
{

CmdQueue::CmdQueue(QObject *parent)
    : m_executing(false),
      m_pLink(nullptr)
{
    Q_UNUSED(parent);
}

CmdQueue::~CmdQueue()
{
}


//-----------------------------------------------------------------

void CmdQueue::eraseCmd()
{
    m_cmd.second->disconnect();
    m_cmd.second.clear();
    m_cmd = CmdPair();
}

//-----------------------------------------------------------------

void CmdQueue::onRcvData(const QByteArray &data)
{
    //    qDebug() << "FwLoader::onRcvData: " << data.toHex();
    if (!m_executing) return;
    if (data.isEmpty() || m_cmd.second.isNull()) return;
    m_cmd.second->rcvData(data);
}

//-----------------------------------------------------------------

void CmdQueue::processQueue()
{
    //    qDebug() << "FwLoader::processQueue : " << m_queue.size();
    if (m_queue.isEmpty())
    {
        m_executing = false;
        eraseCmd();
        return;
    }

    m_cmd = m_queue.dequeue();
    QObject::connect(m_cmd.second.data(), SIGNAL(sendData(QByteArray)), this, SLOT(onCmdSendData(QByteArray)));
    QObject::connect(m_cmd.second.data(), SIGNAL(executed()), this, SLOT(onExecuted()));
    QObject::connect(m_cmd.second.data(), SIGNAL(execError(StandCmd::ErrorType)), this, SLOT(onExecError(StandCmd::ErrorType)));
    m_cmd.second->execute();
}

//-----------------------------------------------------------------

void CmdQueue::onExecuted()
{
    QByteArray data = m_cmd.second->getResponse();
    qDebug() << "CmdQueue::onExecuted: " << data.toHex();
    qDebug() << "CmdQueue::onExecuted: owner: " << m_cmd.first;
    m_cmd.first->onRcvData(data);
//    eraseCmd();
    processQueue();
}

//-----------------------------------------------------------------

void CmdQueue::onExecError(StandCmd::ErrorType type)
{
    // TODO Processing Error type
    Q_UNUSED(type);

    qDebug() << "CmdQueue::onExecError: size: " << m_queue.size();
//    if (m_queue.isEmpty()) { eraseCmd(); return; }
    processQueue();
}

//-----------------------------------------------------------------

void CmdQueue::onCmdSendData(const QByteArray &data)
{
    if (data.isEmpty() || !m_pLink) return;
    m_pLink->sendData(data);
}

//-----------------------------------------------------------------

void CmdQueue::setLink(trans::SerialClient *ptr)
{
    if (!ptr) return;

    if (m_pLink) m_pLink->disconnect();
    m_pLink = ptr;
    QObject::connect(m_pLink, SIGNAL(rcvData(QByteArray)), SLOT(onRcvData(QByteArray)));
}

//-----------------------------------------------------------------

void CmdQueue::add(CmdQueue::CmdPair cmd)
{
    qDebug() << "CmdQueue::add" << cmd;
    if (!cmd.first || cmd.second.isNull()) return;
    m_queue.enqueue(cmd);
}

//-----------------------------------------------------------------

void CmdQueue::execute()
{
    if (m_executing || !m_pLink) return;

    m_executing = true;
    processQueue();
}

//-----------------------------------------------------------------

void CmdQueue::clear()
{
    qDebug() << "CmdQueue::clear";
    m_queue.clear();
}

//-----------------------------------------------------------------

}    // namespace stand

