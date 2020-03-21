<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<table cellpadding="3" cellspacing="3">

  <tr>

    <td class="list-filter-pane" valign="top" width="200">

      <include src="/packages/ah-util/www/search-widget" base_url=@base_url;noquote@>

      <listfilters name="scripts"></listfilters>

    </td>

    <td class="list-list-pane" valign="top">

      <listtemplate name="scripts"></listtemplate>

    </td>

  </tr>

</table>

