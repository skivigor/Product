#ifndef LABELPRINTER_H
#define LABELPRINTER_H

#include <QObject>

namespace label
{

class LabelPrinter : public QObject
{
    Q_OBJECT

private:
    QString m_devicePath;

private:
    LabelPrinter(const LabelPrinter&);
    LabelPrinter& operator=(const LabelPrinter&);

public:
    explicit LabelPrinter(const QString &devicePath, QObject *parent = nullptr);
    ~LabelPrinter();

signals:

public slots:
    bool print(const QString &profile, const QStringList &args, int num = 1);
};


}    // namespace label


#endif // LABELPRINTER_H
