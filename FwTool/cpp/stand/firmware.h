#ifndef FIRMWARE_H
#define FIRMWARE_H

#include <QMap>
#include <QByteArray>

namespace stand
{

struct FirmwareBlock
{
    QByteArray Data;
    quint16    Crc;
};

class Firmware
{
private:
    QMap<int, FirmwareBlock> m_map;
    const int    m_maxBlockSize;
    QString      m_fileName;
    int          m_fileSize;
    QByteArray   m_md5Hash;

private:
    Firmware(const Firmware&);
    Firmware& operator=(const Firmware&);

    void construct(const QByteArray &data);

public:
    explicit Firmware(const QString &path, int maxBlockSize);
    explicit Firmware(const QString &fileName, const QByteArray &data, int maxBlockSize);
    ~Firmware();

    QString getFileName() const    { return m_fileName; }
    int getFileSize() const        { return m_fileSize; }
    int getMaxBlockSize() const    { return m_maxBlockSize; }
    int getBlocksNum() const       { return m_map.size(); }
    QByteArray getMd5Hash() const  { return m_md5Hash; }
//    FirmwareCmdProfile getCmdProfile() const   { return m_cmdSet; }
    int getBlockSize(int num) const;
    FirmwareBlock getBlock(int num) const;

};


}    // namespace stand


#endif // FIRMWARE_H
