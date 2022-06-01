#include "l2stuffbytes.h"

#include <QDebug>
#include "assert.h"

namespace trans
{

L2StuffBytes::L2StuffBytes(quint8 startByte, quint8 stopByte, quint8 stuffByte)
    : m_startByte(startByte),
      m_stopByte(stopByte),
      m_stuffByte(stuffByte)
{
}

//-----------------------------------------------------------------

void L2StuffBytes::addFlags(QByteArray &data) const
{
    data.push_front(static_cast<char>(m_startByte));     // add START BYTE
    data.push_back(static_cast<char>(m_stopByte));       // add STOP BYTE
}

//-----------------------------------------------------------------

void L2StuffBytes::delFlags(QByteArray &data) const
{
    data.chop(1);                     // del STOP BYTE
    data.remove(0, 1);                // del START BYTE
}

//-----------------------------------------------------------------

unsigned short L2StuffBytes::Crc16(char *pcBlock, int len) const
{
    unsigned short crc = 0xFFFF;
    unsigned char i;

    while( len-- )
    {
        crc ^= *pcBlock++ << 8;
        for( i = 0; i < 8; i++ ) crc = crc & 0x8000 ? ( crc << 1 ) ^ 0x1021 : crc << 1;
    }

    return crc;
}

//-----------------------------------------------------------------

void L2StuffBytes::addStuffBytes(QByteArray &data) const
{
    quint8 currentElement;

    for (int i = 0; i < data.size(); i++)
    {
        currentElement = static_cast<quint8>(data.at(i));

        if (currentElement == m_startByte)
        {
            data.remove(i, 1);
            data.insert(i, static_cast<char>(m_stuffByte));
            data.insert(i + 1, 0x1E);
        }

        if (currentElement == m_stopByte)
        {
            data.remove(i, 1);
            data.insert(i, static_cast<char>(m_stuffByte));
            data.insert(i + 1, 0x1D);
        }

        if (currentElement == m_stuffByte)
        {
            data.insert(i + 1, 0x10);
        }
    }
}

//-----------------------------------------------------------------

void L2StuffBytes::delStuffBytes(QByteArray &data) const
{
    quint8 currentElement;
    quint8 nextElement;

    for (int i = 0; i < data.size() - 1; i++)
    {
        currentElement = static_cast<quint8>(data.at(i));

        if (currentElement == m_stuffByte)
        {
            nextElement = static_cast<quint8>(data.at(i + 1));

            if (nextElement == 0x10)
            {
                data.remove(i + 1, 1);
            }

            if (nextElement == 0x1E)
            {
                data.remove(i + 1, 1);
                data.remove(i, 1);
                data.insert(i, static_cast<char>(0xE1));
            }

            if (nextElement == 0x1D)
            {
                data.remove(i + 1, 1);
                data.remove(i, 1);
                data.insert(i, static_cast<char>(0xE2));
            }
        }
    }
}

//-----------------------------------------------------------------

QByteArray L2StuffBytes::packData(const QByteArray &data)
{
    if (data.isEmpty()) return QByteArray();
    QByteArray ba = data;

    quint16 crc = Crc16(ba.data(), ba.size());
    quint8 hByte = (crc >> 8) & 0xFF;
    quint8 lByte = crc & 0xFF;

    ba.append(static_cast<char>(hByte));
    ba.append(static_cast<char>(lByte));

    addStuffBytes(ba);
    addFlags(ba);

    ba.prepend(static_cast<char>(0xFA));
    return  ba;
}

//-----------------------------------------------------------------

QByteArrayList L2StuffBytes::unpackData(const QByteArray &data)
{
    if (data.size() < 7) return QList<QByteArray>();
    QByteArray ba = data;
    QByteArrayList list;

    ba.remove(0, 4);
    quint8 element;
    int i, j;
    int startInd = 0;
    int endInd = 0;
    bool startDefined = false;
    bool endDefined = false;

    QByteArray frame;

    for (i = 0; i < ba.size(); i++)
    {
        element = static_cast<quint8>(ba.at(i));

        if (element == m_startByte)
        {
            startInd = i;
            startDefined = true;
        }

        if (element == m_stopByte)
        {
            endInd = i;
            endDefined = true;
        }

        if (startDefined && endDefined && (startInd < endInd))
        {
            for (j = startInd; j <= endInd; j++)
            {
                element = static_cast<quint8>(ba.at(j));
                frame.append(static_cast<char>(element));
            }

            delFlags(frame);
            delStuffBytes(frame);

            // Check CRC
            quint8 recvCrcHighByte = static_cast<quint8>(frame.at(frame.size() - 2));
            quint8 recvCrcLowByte = static_cast<quint8>(frame.at(frame.size() - 1));
            quint16 recvCrc = static_cast<quint16>((recvCrcHighByte << 8) + recvCrcLowByte);   // receive CRC16 (2 bytes)
            frame.chop(2);      // remove CRC16 from frame

            quint16 calcCrc = Crc16(frame.data(), frame.size());
            if (calcCrc == recvCrc) list.append(frame);

            frame.clear();
            startDefined = false;
            endDefined = false;
        }
    }

    return list;
}

//-----------------------------------------------------------------

}    // namespace trans

