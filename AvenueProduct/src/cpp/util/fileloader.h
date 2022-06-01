#ifndef FILELOADER_H
#define FILELOADER_H

#include <QObject>
#include <QString>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>

#include <vector>

namespace util
{

class FileLoader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString fwName READ getFwName NOTIFY fwNameChanged)
    Q_PROPERTY(QString fwMd5 READ getFwMd5 NOTIFY fwMd5Changed)
    Q_PROPERTY(QString fwFile READ getFwFile NOTIFY fwFileChanged)

private:
    QString  m_fwName;
    QString  m_fwMd5;    // base64
    QString  m_fwFile;   // base64

private:
    explicit FileLoader(QObject *parent = nullptr);
    ~FileLoader();
    FileLoader(const FileLoader&);
    FileLoader& operator=(const FileLoader&);

public:
    static FileLoader& instance();

signals:
    void fwNameChanged();
    void fwMd5Changed();
    void fwFileChanged();

public slots:
    bool isFileExists(const QString &path) const;
    QStringList getFilesNameList(const QString &dirPath, QStringList filters);
    QString getFileAsString(const QString &path);
    QByteArray getFileAsBin(const QString &path);
    QJsonDocument getFileAsJsonDoc(const QString &path);
    QJsonObject getJsonObject(const QString &path, const QString &chapter);
    QJsonArray getJsonArray(const QString &path, const QString &chapter);
    QStringList toStringList(const QList<QUrl> &list);

    bool saveFile(const QString &path, const QString &data) const;
    bool saveFileAsJsonDoc(const QString &path, const QJsonObject &obj) const;

    // Firmware to db
    QString getFwName() const   { return m_fwName; }
    QString getFwMd5() const    { return m_fwMd5; }
    QString getFwFile() const   { return m_fwFile; }
    bool loadFirmwareFile(const QString &filePath);

};


}    // namespace util


#endif // FILELOADER_H
