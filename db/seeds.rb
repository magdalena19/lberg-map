# use high id's because auto-generated id's at form based creation begins with 1
lorem_ipsum = '<b>Lorem ipsum dolor sit amet</b><br><br>Consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.'
lorem_ipsum_arabic = '<b>عرض حادثة سبتمبر مع</b><br><br>ما لفشل الأحمر أضف, ضرب إحكام لمحاكم الشّعبين و. عل كلا بقسوة اعلان جديداً, الى وجزر غريمه هو. كل حين مدينة الإيطالية, وبعد استبدال انه ان. ٣٠ بحق اللا وباءت, عل تحرّك الغالي بعض.و جهة رئيس وبغطاء مسؤولية, ان مايو ومضى الدولارات ومن. وصل الثالث المجتمع والمعدات بل, حصدت ألمّ الأهداف بعد من. من وسوء وقامت بحق, لم مما ساعة غينيا, تعد من شعار الموسوعة. مع للجزر واستمر الموسوعة ومن. غضون وبدأت شمولية بحق تم. حول عل ووصف مليارات وحلفاؤها, وقبل أعمال ثم عدم. بـ عدم ليركز بالتوقيع, أم فقد جيوب معارضة. دنو ما الخطّة الأرواح الولايات, بل مئات كثيرة دول, تحت المشترك ولكسمبورغ الإيطالية إذ. هو دون أعلنت الربيع،, وحتى مقاومة للحكومة إذ جُل. في ولم وحتى انذار, إذ دنو هُزم وتنصيب الشرقية, ماشاء الانجليزية الأوروبيّون جهة أي. ووصف المضي إستيلاء من قام, دأبوا بالمحور انه و.'

Place.new(id: 1001,
          name: 'Seed Place',
          street: 'Magdalenenstr.',
          house_number: 22,
          postal_code: '10365',
          city: 'Berlin',
          latitude: 52.5,
          longitude: 13.5,
          description_en: lorem_ipsum,
          description_de: lorem_ipsum,
          description_fr: lorem_ipsum,
          description_ar: lorem_ipsum_arabic,
          reviewed: false
         ).save(validate: false)

Place.new(id: 1002,
          name: 'Another random place',
          street: 'Methfesselstr.',
          house_number: 5,
          postal_code: '10965',
          city: 'Berlin',
          latitude: 52.55,
          longitude: 13.4,
          description_en: lorem_ipsum,
          description_de: lorem_ipsum,
          description_fr: lorem_ipsum,
          description_ar: lorem_ipsum_arabic,
          reviewed: true
         ).save(validate: false)

Place.new(id: 1003,
          name: 'Haus vom Nikolaus',
          street: 'Platz der Republik',
          house_number: 1,
          postal_code: '11011',
          city: 'Berlin',
          latitude: 52.54,
          longitude: 13.3,
          description_en: lorem_ipsum,
          description_de: lorem_ipsum,
          description_fr: lorem_ipsum,
          description_ar: lorem_ipsum_arabic,
          reviewed: false
         ).save(validate: false)

Category.create(id: 1,
                name_en: 'Playground',
                name_de: 'Spielplatz',
                name_fr: 'Aire de jeu',
                name_ar: 'ملعب'
               )

Category.create(id: 2,
                name_en: 'Library',
                name_de: 'Bibliothek',
                name_fr: 'Bibliothèque',
                name_ar: 'مكتبة'
               )

Category.create(id: 3,
                name_en: 'Free Wifi',
                name_de: 'Kostenloses Wlan',
                name_fr: 'Wifi gratuit',
                name_ar: 'واي فاي مجانا'
               )

# Users
User.create(id: 5000,
            name: 'admin',
            email: 'admin@test.com',
            password: 'secret',
            password_confirmation: 'secret',
            is_admin: true).save
User.create(id: 5001,
            name: 'user',
            email: 'user@test.com',
            password: 'secret',
            password_confirmation: 'secret',
            is_admin: false).save
