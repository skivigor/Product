#ifndef FIRMWARE_H
#define FIRMWARE_H

#include <QObject>
#include <QMap>
#include <QByteArray>

namespace load
{

struct FirmwareCmdProfile
{
    quint8 CmdSetVer;
    quint8 CmdGetVer;
    quint8 CmdWriteBlock;
    quint8 CmdCheck;
};

struct FirmwareBlock
{
    QByteArray Data;
    quint16    Crc;
};

class Firmware : public QObject
{
    Q_OBJECT

private:
    const QString            m_descr;
    QMap<int, FirmwareBlock> m_map;
    FirmwareCmdProfile       m_cmdSet;
    const int    m_maxBlockSize;
    QString      m_fileName;
    int          m_fileSize;
    QByteArray   m_md5Hash;

private:
    Firmware(const Firmware&);
    Firmware& operator=(const Firmware&);

public:
    explicit Firmware(const QString &descr, const QString &path,
                      const FirmwareCmdProfile &cmd, int maxBlockSize,
                      QObject *parent = nullptr);
    ~Firmware();

signals:

public slots:
    QString getDescription() const { return m_descr; }
    QString getFileName() const    { return m_fileName; }
    int getFileSize() const        { return m_fileSize; }
    int getMaxBlockSize() const    { return m_maxBlockSize; }
    int getBlocksNum() const       { return m_map.size(); }
    QByteArray getMd5Hash() const  { return m_md5Hash; }
    FirmwareCmdProfile getCmdProfile() const   { return m_cmdSet; }
    int getBlockSize(int num) const;
    FirmwareBlock getBlock(int num) const;

};


}    // namespace load


#endif // FIRMWARE_H
