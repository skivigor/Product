#ifndef AVTESTCLASS_H
#define AVTESTCLASS_H

#include <QObject>

namespace avtest
{

class AvTestClass : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString fwName READ getFwName NOTIFY fwNameChanged)
    Q_PROPERTY(QString fwMd5 READ getFwMd5 NOTIFY fwMd5Changed)
    Q_PROPERTY(QString fwFile READ getFwFile NOTIFY fwFileChanged)

private:
    QString  m_fwName;
    QString  m_fwMd5;
    QString  m_fwFile;

private:
    AvTestClass(const AvTestClass&);
    AvTestClass& operator=(const AvTestClass&);

public:
    explicit AvTestClass(QObject *parent = nullptr);
    ~AvTestClass();

signals:
    void fwNameChanged();
    void fwMd5Changed();
    void fwFileChanged();

public slots:
    QString getFwName() const   { return m_fwName; }
    QString getFwMd5() const    { return m_fwMd5; }
    QString getFwFile() const   { return m_fwFile; }

    void show(const QString &base64);
    void file(const QString &file);

    void openFile(const QString &filePath);
    void parseFile(const QString &md5, const QString &file);

    void test();
};


}    // namespace avtest


#endif // AVTESTCLASS_H
