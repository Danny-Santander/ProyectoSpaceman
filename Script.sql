select * from public.tickets t;
select * from public.productos p;

select hora
from public.tickets
where hora is not null
and hora !~ '^\d{2}:\d{2}(:\d{2})?$'
and hora = 'NaN';--742

update public.tickets set ean_desc = upper(trim(ean_desc));

update public.tickets set hora = '00:00:00'
where hora is not null
and hora !~ '^\d{2}:\d{2}(:\d{2})?$'
and hora = 'NaN';

alter table public.tickets alter column fecha type date using fecha::date;
alter table public.tickets alter column hora type time without time zone using hora::time;
alter table public.tickets alter column precio_regular type numeric(15,2) using precio_regular::numeric;
alter table public.tickets alter column precio_promocional type numeric(15,2) using precio_promocional::numeric;
alter table public.tickets alter column ultmodificacion type timestamp without time zone using ultmodificacion::timestamp;

alter table public.productos alter column subcategoria_nueva type text using subcategoria_nueva::text;

update public.productos set categoria = upper(trim(categoria));
update public.productos set descripcion = 'NO DEFINIDO' where descripcion = 'NaN';
update public.productos set contenido = 0 where contenido = 'NaN';
update public.productos set pesovolumen = 0 where pesovolumen = 'NaN';
update public.productos set granfamilia = 'NO DEFINIDO' where granfamilia = 'NaN';
update public.productos set familia = 'NO DEFINIDO' where familia = 'NaN';
update public.productos set categoria_nueva = 'NO DEFINIDO' where categoria_nueva = 'NaN';
update public.productos set subcategoria_nueva = 'NO DEFINIDO' where subcategoria_nueva = 'NaN';

SET lc_time = 'es_ES';

create table calendario as
select fecha::date fecha,
   extract(YEAR FROM fecha)::int año,
   lpad(extract(MONTH FROM fecha)::text,2,'0') mes,
   lpad(extract(DAY FROM fecha)::text,2,'0') dia,
   to_char(fecha, 'TMMonth') nombre_mes,
   to_char(fecha, 'TMDay') nombre_dia,
   extract(QUARTER FROM fecha)::int trimestre,
   case when extract(DOW FROM fecha) between 1 and 5 then 'S' else 'N' end es_dia_laboral
from generate_series('2023-01-01'::DATE, '2034-12-31'::DATE, '1 day') fecha;

select * from public.calendario;

alter table public.calendario add constraint pk_calendario primary key (fecha);
alter table public.tickets add constraint pk_tickets primary key (eancode, idcadena,id);
alter table public.productos add constraint pk_productos primary key (idcadena,eancode,id);

alter table if exists public.tickets
add constraint fk_tickets_calendario foreign key (fecha)
references public.calendario (fecha)
on update cascade
on delete cascade;

create index idx_tickets_1 on public.tickets (eancode,idcadena);
create index idx_tickets_2 on public.tickets (fecha);
create index idx_tickets_3 on public.tickets (id);
create index idx_tickets_4 on public.tickets (anulado);
create index idx_tickets_5 on public.tickets (punto);
create index idx_productos_1 on public.productos (idcadena,eancode);
create index idx_productos_2 on public.productos (id);
create index idx_productos_3 on public.productos (categoria);
create index idx_productos_4 on public.productos (descripcion);

select t.fecha, t.ticket, t.eancode, p.descripcion, count(*) cant
from public.tickets t
inner join public.productos p on t.eancode = p.eancode and t.idcadena = p.idcadena
group by t.fecha, t.ticket, t.eancode, p.descripcion
having count(*) > 2
order by 1;

--Total de ventas por categoria
select p.categoria, count(distinct t.ticket) cantidad_ventas
from public.productos p
inner join public.tickets t on p.idcadena = t.idcadena and p.eancode = t.eancode
where t.anulado = false
group by p.categoria
order by 1;

--Total de productos vendidos por categoria
select p.descripcion, p.categoria, count(distinct t.ticket) cantidad_ventas
from public.productos p
inner join public.tickets t on p.idcadena = t.idcadena and p.eancode = t.eancode
where t.anulado = false
group by p.descripcion, p.categoria
order by 2, 1;

-- Facturación por día 
select t.fecha, round(sum(t.unidades_vendidas * t.precio_promocional)) facturacion
from public.tickets t
where t.anulado = false
group by t.fecha
order by 1;

-- Cantidad Total de Productos Vendidos
select t.fecha, t.ean_desc producto, count(*) cant
from public.tickets t
where t.anulado = false
group by t.fecha, t.ean_desc
order by 1,2;

--Cantidad Total de Tickets
select t.fecha, t.ticket, count(*) cant 
from public.tickets t
where t.anulado = false
group by t.fecha, t.ticket
order by 1,2;

--Los 5 productos más vendidos en el último mes
select to_char(t.fecha,'YYYY-MM') año_mes,
   t.ean_desc producto,
   count(distinct t.fecha::text ||'-'||t.ticket) cant_ventas
from public.tickets t 
where t.fecha >= date_trunc('month',(select max(t2.fecha) from public.tickets t2) - interval '3 month')
  and t.anulado = false
group by to_char(t.fecha,'YYYY-MM'), t.ean_desc
order by 2
limit 5;

-- Obtener el total de ingresos generados por categoría en las últimas 3 semanas
select p.categoria, round(sum(t.unidades_vendidas * t.precio_promocional)) ingresos
from public.productos p
inner join public.tickets t on p.idcadena = t.idcadena and p.eancode = t.eancode
where t.fecha >= (select max(t2.fecha) - interval '3 weeks' from public.tickets t2)
  and t.anulado = false
group by p.categoria
order by 2 desc;

-- Listar los días con mayor venta y cantidad de tickets.
select t.fecha,
   count(distinct t.ticket) cant_ticket,
   round(sum(t.unidades_vendidas * t.precio_promocional)) total_ventas
from public.tickets t
where t.anulado = false
group by t.fecha
order by 3 desc, 2 desc
limit 5;

-- Mostrar la categoría con el mayor volumen de ventas por sucursal.
select DISTINCT ON (t.punto)
   t.punto,
   p.categoria,
   round(sum(unidades_vendidas)) vol_ventas
from public.productos p
inner join public.tickets t on p.idcadena = t.idcadena and p.eancode = t.eancode
group by t.punto, p.categoria
order by t.punto, p.categoria desc;
