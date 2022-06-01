#ifndef POWERFACTORY_H
#define POWERFACTORY_H

#include <QObject>

namespace power
{

class PowerFactory : public QObject
{
    Q_OBJECT

private:
    PowerFactory(const PowerFactory&);
    PowerFactory& operator=(const PowerFactory&);

public:
    explicit PowerFactory(QObject *parent = nullptr);
    ~PowerFactory();

signals:

public slots:
    QObject *createPowerSupplyWithTcp(const QString &uri, int port);

};


}    // namespace power


#endif // POWERFACTORY_H
