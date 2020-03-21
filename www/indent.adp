<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<table>

  <tr bgcolor=#6699cc>
    <th>Codice</th>
    <th align=left>Descrizione</th>
  </tr>

  <multiple name=scripts>

    <if @scripts.rownum@ odd>
      <tr bgcolor=#eeeeee>
    </if>
    <if @scripts.rownum@ even>
      <tr bgcolor=#ffffff>
    </if>
        <td>@scripts.indent;noquote@@scripts.item_id;noquote@</th>
        <td>@scripts.name;noquote@</th>
    </tr>

  </multiple>

</table>


