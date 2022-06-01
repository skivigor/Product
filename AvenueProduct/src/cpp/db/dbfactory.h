#ifndef DBFACTORY_H
#define DBFACTORY_H

#include <QObject>

namespace db
{

class DbFactory : public QObject
{
    Q_OBJECT

private:
    DbFactory(const DbFactory&);
    DbFactory& operator=(const DbFactory&);

public:
    explicit DbFactory(QObject *parent = nullptr);
    ~DbFactory();

signals:

public slots:
    QObject *createDbClient() const;
};


}    // namespace db


#endif // DBFACTORY_H
