import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;
import java.util.Vector;
class MainForm extends JFrame {
    private JTable table;
    private DefaultTableModel model;
    private String url = "jdbc:postgresql://localhost:5432/bd";
    private String user = "postgres";
    private String password = "12345678";
    private Boolean Flag = false;
    private ResultSet rs;
    private PreparedStatement pst;
    private Connection conn;
    private Statement stm;
    public MainForm() {
        setTitle("bd");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(600, 400);

        JMenuBar menuBar = new JMenuBar();
        setJMenuBar(menuBar);

        JMenu tablesMenu = new JMenu("Таблицы");
        menuBar.add(tablesMenu);

        JMenuItem Item1 = new JMenuItem("Филиал");
        Item1.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                showTable1(1);
            }
        });
        tablesMenu.add(Item1);

        JMenuItem Item2 = new JMenuItem("Страховые агенты");
        Item2.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                showTable1(2);}});
        tablesMenu.add(Item2);

        JMenuItem Item3 = new JMenuItem("договор");
        Item3.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                showTable1(3);}});
        tablesMenu.add(Item3);

        JMenuItem Item4 = new JMenuItem("вид страхования");
        Item4.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                showTable1(4);}});
        tablesMenu.add(Item4);


        JMenu editMenu = new JMenu("Правки");
        menuBar.add(editMenu);

        JMenuItem saveItem = new JMenuItem("Сохранить");
        saveItem.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                saveTable();
            }
        });
        editMenu.add(saveItem);

        JMenuItem addItem = new JMenuItem("Добавить");
        addItem.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {addRow();}
        });
        editMenu.add(addItem);

        JMenuItem deleteItem = new JMenuItem("Удалить");
        deleteItem.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                deleteRow();
            }
        });
        editMenu.add(deleteItem);

        JMenu queriesMenu = new JMenu("Запросы");
        menuBar.add(queriesMenu);

        JMenuItem Poisk_po_fam = new JMenuItem("поиск по фамилии");
        Poisk_po_fam.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                showpoisk_po_fam();
            }
        });
        queriesMenu.add(Poisk_po_fam);

        JMenuItem kol_dog_ag = new JMenuItem("кол-во договоров у каждого агента");
        kol_dog_ag.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                showkol_dog_ag();
            }
        });
        queriesMenu.add(kol_dog_ag);

        JMenu functionMenu = new JMenu("Вызов функции");
        menuBar.add(functionMenu);

        JMenuItem carInfoItem = new JMenuItem("зарплата агента за договор");
        carInfoItem.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                showFunc();
            }
        });
        functionMenu.add(carInfoItem);

        model = new DefaultTableModel();
        table = new JTable(model);
        JScrollPane scrollPane = new JScrollPane(table);
        getContentPane().add(scrollPane, BorderLayout.CENTER);
    }
    private void showTable1(int number) {
        model.setColumnCount(0);
        model.setRowCount(0);

        try {
            conn = DriverManager.getConnection(url, user, password);
            if (number == 1){
                pst = conn.prepareStatement("SELECT * FROM filial");
                rs = pst.executeQuery();}
            if (number == 2){
                pst = conn.prepareStatement("SELECT * FROM strahovoi_agent");
                rs = pst.executeQuery();}
            if
            (number == 3){
                pst = conn.prepareStatement("SELECT * FROM dogovor");
                rs = pst.executeQuery();}
            if (number == 4){
                pst = conn.prepareStatement("SELECT * FROM vid_strahovania");
                rs = pst.executeQuery();}

            Flag = true;

            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
                model.addColumn(rs.getMetaData().getColumnName(i));
            }

            while (rs.next()) {
                Object[] row = new Object[rs.getMetaData().getColumnCount()];
                for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
                    row[i - 1] = rs.getObject(i);
                }
                model.addRow(row);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
    private void deleteRow() {
        int selectedRow = table.getSelectedRow();
        if (selectedRow != -1) {
            try {
                conn = DriverManager.getConnection(url, user, password);
                String tableName = rs.getMetaData().getTableName(1); // Получаем имя таблицы из JComboBox

                stm = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
                rs = stm.executeQuery("SELECT * FROM " + tableName+""); // Выполняем запрос для выбранной таблицы
                rs.absolute(selectedRow + 1); // Перемещаем курсор на выбранную строку
                if (tableName.equals("filial")){
                    int id = rs.getInt("kod_filiala");
                    stm.executeUpdate("DELETE FROM " + tableName + " WHERE kod_filiala = " + id);
                    model.removeRow(selectedRow);
                    JOptionPane.showMessageDialog(this, "Удалено", "", JOptionPane.INFORMATION_MESSAGE);}
                if (tableName.equals("strahovoi_agent")){
                    int id = rs.getInt("kod_agenta");
                    stm.executeUpdate("DELETE FROM " + tableName + " WHERE Kod_agenta = " + id);
                    model.removeRow(selectedRow);
                    JOptionPane.showMessageDialog(this, "Удалено", "", JOptionPane.INFORMATION_MESSAGE);}
                if (tableName.equals("dogovor")){
                    int id = rs.getInt("nomer_dogovora");
                    stm.executeUpdate("DELETE FROM " + tableName + " WHERE nomer_dogogvora = " + id);
                    model.removeRow(selectedRow);
                    JOptionPane.showMessageDialog(this, "Удалено", "", JOptionPane.INFORMATION_MESSAGE);}
                if (tableName.equals("vid_strahovania")){
                    int id = rs.getInt("kod_vida_strahovania");
                    stm.executeUpdate("DELETE FROM " + tableName + " WHERE kod_vida_strahovania = " + id);
                    model.removeRow(selectedRow);
                    JOptionPane.showMessageDialog(this, "Удалено", "", JOptionPane.INFORMATION_MESSAGE);}
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(this, e.getMessage(), "Ошибка", JOptionPane.ERROR_MESSAGE);
            }
        } else {
            JOptionPane.showMessageDialog(this, "Пожалуйста, выберите строку для удаления");
        }

    }
    private void addRow(){
        if (Flag){
            model.addRow(new Vector<>());
            JOptionPane.showMessageDialog(this, "После добавления необходимо сохранить измененения", "Внимание", JOptionPane.INFORMATION_MESSAGE);}
        else JOptionPane.showMessageDialog(this, "Для добавления строки откройте таблицу", "Внимание", JOptionPane.INFORMATION_MESSAGE);
    }
    public void saveTable() {
        try {
            conn = DriverManager.getConnection(url, user, password); // Устанавливаем соединение с базой данных
            String tableName = rs.getMetaData().getTableName(1); // Получаем имя таблицы из результирующего набора данных

            for (int i = 0; i < model.getRowCount(); i++) { // Итерация по строкам таблицы
                StringBuilder query = new StringBuilder("INSERT INTO ");
                String condition = "";

                // Формирование SQL-запроса в зависимости от имени таблицы
                if (tableName.equals("filial")) {
                    query.append("filial (");
                    condition = "kod_filiala";
                } else if (tableName.equals("strahovoi_agent")) {
                    query.append("strahovoi_agent (");
                    condition = "kod_agenta";
                } else if (tableName.equals("dogovor")) {
                    query.append("dogovor (");
                    condition = "nomer_dogovora";
                } else if (tableName.equals("vid_strahovania")) {
                    query.append("vid_strahovania (");
                    condition = "kod_vida_strahovania";
                }

                // Формирование списка столбцов для вставки
                for (int j = 0; j < model.getColumnCount(); j++) {
                    query.append(model.getColumnName(j));
                    if (j != model.getColumnCount() - 1) {
                        query.append(", ");
                    }
                }

                query.append(") VALUES (");

                // Формирование значений для вставки
                for (int j = 0; j < model.getColumnCount(); j++) {
                    query.append("'").append(model.getValueAt(i, j)).append("'");
                    if (j != model.getColumnCount() - 1) {
                        query.append(", ");
                    }
                }

                query.append(") ON CONFLICT (").append(condition).append(") DO UPDATE SET ");

                // Формирование части запроса для обновления данных при конфликте
                for (int j = 0; j < model.getColumnCount(); j++) {
                    query.append(model.getColumnName(j)).append(" = '").append(model.getValueAt(i, j)).append("'");
                    if (j != model.getColumnCount() - 1) {
                        query.append(", ");
                    }
                }

                System.out.println(query.toString()); // Вывод SQL-запроса в консоль для отладки
                pst = conn.prepareStatement(query.toString());
                pst.executeUpdate(); // Выполнение SQL-запроса

            }

            JOptionPane.showMessageDialog(this, "Изменения сохранены!"); // Вывод сообщения об успешном сохранении
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(this, ex.getMessage(), "Ошибка", JOptionPane.ERROR_MESSAGE); // Вывод сообщения об ошибке
        }
    }
    private void showpoisk_po_fam() {
        String fam = JOptionPane.showInputDialog("Введите фамилию:");
        if (fam != null && !fam.isEmpty()) {
            model.setColumnCount(0);
            model.setRowCount(0);

            try {
                Connection conn = DriverManager.getConnection(url, user, password);
                PreparedStatement pst = conn.prepareStatement("SELECT * from strahovoi_agent\r\nwhere familia like '"+fam+"'");

                ResultSet rs = pst.executeQuery();

                for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++)
                {
                    model.addColumn(rs.getMetaData().getColumnName(i));
                }

                while (rs.next()) {
                    Object[] row = new Object[rs.getMetaData().getColumnCount()];
                    for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++)
                    {
                        row[i - 1] = rs.getObject(i);
                    }
                    model.addRow(row);
                }
                rs.close();
                pst.close();
                conn.close();
            } catch (Exception ex) {

                ex.printStackTrace();

            }
        }

    }
    private void showkol_dog_ag() {

        model.setColumnCount(0);
        model.setRowCount(0);

        try {
            Connection conn = DriverManager.getConnection(url, user, password);
            PreparedStatement pst = conn.prepareStatement("SELECT strahovoi_agent.kod_agenta, strahovoi_agent.familia, Count(dogovor.kod_vida_strahovania) \r\nFrom dogovor, strahovoi_agent\r\nwhere dogovor.kod_agenta=strahovoi_agent.kod_agenta \r\nGroup by strahovoi_agent.kod_agenta");

            ResultSet rs = pst.executeQuery();

            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
                model.addColumn(rs.getMetaData().getColumnName(i));
            }

            while (rs.next()) {
                Object[] row = new Object[rs.getMetaData().getColumnCount()];
                for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
                    row[i - 1] = rs.getObject(i);
                }
                model.addRow(row);
            }

            rs.close();
            pst.close();
            conn.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private void showFunc() {
        String nom_dog = JOptionPane.showInputDialog("Введите номер договора:");
        if (nom_dog != null && !nom_dog.isEmpty()) {
            model.setColumnCount(0);
            model.setRowCount(0);

            try {
                Connection conn = DriverManager.getConnection(url, user, password);
                PreparedStatement pst = conn.prepareStatement("SELECT * FROM ZP_ag("+Integer.parseInt(nom_dog)+")");

                ResultSet rs = pst.executeQuery();

                for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
                    model.addColumn(rs.getMetaData().getColumnName(i));
                }

                while (rs.next()) {
                    Object[] row = new Object[rs.getMetaData().getColumnCount()];
                    for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
                        row[i - 1] = rs.getObject(i);
                    }
                    model.addRow(row);
                }

                rs.close();
                pst.close();
                conn.close();
            } catch (Exception ex) {

                ex.printStackTrace();
                JOptionPane.showMessageDialog(this, "не верный формат номера договора", "Ошибка", JOptionPane.ERROR_MESSAGE);
            }
        }

    }
    public static void main(String[] args) {
        EventQueue.invokeLater(new Runnable() {
            public void run() {
                try {
                    MainForm frame = new MainForm();
                    frame.setVisible(true);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }
}