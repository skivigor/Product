#include "l2flags.h"

#include <QDebug>

namespace trans
{

L2Flags::L2Flags(quint8 flag, QObject *parent)
    : m_flag(flag)
{
    Q_UNUSED(parent)
    m_timer.setSingleShot(true);
    QObject::connect(&m_timer, &QTimer::timeout, this, &L2Flags::onTimeout, Qt::QueuedConnection);
}

//-----------------------------------------------------------------

void L2Flags::onTimeout()
{
    m_queue.clear();
}

//-----------------------------------------------------------------

QByteArray L2Flags::packData(const QByteArray &data)
{
    if (data.isEmpty()) return  QByteArray();
    QByteArray ba;
    int idx = 0;

    while (idx < data.size())
    {
        quint8 len = static_cast<quint8>(data.at(idx));
        if (len == 0) break;
        if (len > data.size() - idx) break;

        ba.append(static_cast<char>(0xFF));
        ba.append(data.mid(idx, len));
        ba.append(static_cast<char>(0xFF));
        idx += len;
    }

    return ba;
}

//-----------------------------------------------------------------

QByteArrayList L2Flags::unpackData(const QByteArray &data)
{
    m_timer.stop();
    if (data.isEmpty()) return QByteArrayList();
//    qDebug() << "L2Flags::unpackData: input: " << data.toHex();

    QByteArrayList list;
    QByteArray ba(m_queue);
    m_queue.clear();
    ba.append(data);

    int idx = 0;
    int last = -1;
    int size = ba.size();

    while (idx < size)
    {
        quint8 val = static_cast<quint8>(ba.at(idx));
        if (val == m_flag)    // start flag of ie
        {
            last = idx;
            if (idx + 1 > size - 1) break;
            quint8 len = static_cast<quint8>(ba.at(++idx));
            if (len == 0) { idx++; last = -1; continue; }
            if (len == m_flag) continue;
            if (idx + len > size - 1) break;
            val = static_cast<quint8>(ba.at(idx + len));
            if (val == m_flag)   // end flag of ie
            {
                list.append(ba.mid(idx, len));
                idx += len + 1;
                last = -1;
            }
        } else
        {
            idx++;
        }
    }

    if (last >= 0) m_queue = ba.mid(last);
    if (!m_queue.isEmpty()) m_timer.start(50);
//    qDebug() << "L2Flags::unpackData: queue: " << m_queue.toHex();

    return list;
}

//-----------------------------------------------------------------

}    // namespace trans

