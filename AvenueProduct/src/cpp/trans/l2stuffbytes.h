#ifndef L2STUFFBYTES_H
#define L2STUFFBYTES_H

#include "ilevel2.h"

namespace trans
{

class L2StuffBytes : public ILevel2
{
private:
    const quint8   m_startByte;    // 0xE1
    const quint8   m_stopByte;     // 0xE2
    const quint8   m_stuffByte;    // 0xEF

private:
    void addFlags(QByteArray &data) const;
    void delFlags(QByteArray &data) const;
    unsigned short Crc16( char *pcBlock, int len ) const;
    void addStuffBytes(QByteArray &data) const;
    void delStuffBytes(QByteArray &data) const;

public:
    explicit L2StuffBytes(quint8 startByte, quint8 stopByte, quint8 stuffByte);

    // ILevel2 implementation
    QByteArray packData(const QByteArray &data);
    QByteArrayList unpackData(const QByteArray &data);
};


}    // namespace trans


#endif // L2STUFFBYTES_H
