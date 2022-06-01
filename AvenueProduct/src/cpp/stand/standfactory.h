#ifndef LOADFACTORY_H
#define LOADFACTORY_H

#include <QObject>

namespace stand
{

class Stand;

class StandFactory : public QObject
{
    Q_OBJECT

private:
    StandFactory(const StandFactory&);
    StandFactory& operator=(const StandFactory&);

public:
    explicit StandFactory(QObject *parent = nullptr);
    ~StandFactory();

signals:

public slots:
    QObject *createStand();
    QObject *createScanner();

};


}    // namespace stand


#endif // LOADFACTORY_H
