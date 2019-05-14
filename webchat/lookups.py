# -*- coding: utf-8 -*-
from django.db.models import Lookup
from django.db.models import Transform
from django.db.models.fields import Field
from django.db.models.fields import DateField, DateTimeField

class NumFilter(Lookup):
    lookup_name = 'numfilter'

    def as_postgresql(self, qn, connection):
        lhs, lhs_params = self.process_lhs(qn, connection)
        rhs, rhs_params = self.process_rhs(qn, connection)
        params = lhs_params + rhs_params
        return "regexp_replace(%s,'[^0-9]', '', 'g') = regexp_replace(%s,'[^0-9]', '', 'g')" % (lhs, rhs), params
Field.register_lookup(NumFilter)

class Unaccent(Transform):
    lookup_name = 'unaccent'

    def as_postgresql(self, qn, connection):
        lhs, params = qn.compile(self.lhs)
        return "unaccent(%s)" % lhs, params
Field.register_lookup(Unaccent)

class UnaccentILike(Lookup):
    """ field__unaccent__ilike """
    lookup_name = 'ilike'

    def as_postgresql(self, qn, connection):
        lhs, lhs_params = self.process_lhs(qn, connection)
        rhs, rhs_params = self.process_rhs(qn, connection)
        params = lhs_params + rhs_params
        return "%s ilike unaccent(%s)" % (lhs, rhs), params
Unaccent.register_lookup(UnaccentILike)

class Trim(Transform):
    lookup_name = 'trim'

    def as_postgresql(self, qn, connection):
        lhs, params = qn.compile(self.lhs)
        return "TRIM(%s)" % lhs, params

    def as_sqlite(self, qn, connection):
        lhs, params = qn.compile(self.lhs)
        return "TRIM(%s)" % lhs, params
    
Field.register_lookup(Trim)

class toUpper(Transform):
    lookup_name = 'upper'

    def as_postgresql(self, qn, connection):
        lhs, params = qn.compile(self.lhs)
        return "UPPER(%s)" % lhs, params

    def as_sqlite(self, qn, connection):
        lhs, params = qn.compile(self.lhs)
        return "UPPER(%s)" % lhs, params

Field.register_lookup(toUpper)

class toLower(Transform):
    lookup_name = 'lower'

    def as_postgresql(self, qn, connection):
        lhs, params = qn.compile(self.lhs)
        return "LOWER(%s)" % lhs, params
Field.register_lookup(toLower)

class Like(Lookup):
    lookup_name = 'like'

    def as_postgresql(self, qn, connection):
        lhs, lhs_params = self.process_lhs(qn, connection)
        rhs, rhs_params = self.process_rhs(qn, connection)
        return '%s LIKE %s' % (lhs, rhs), lhs_params + rhs_params

    def as_sqlite(self, qn, connection):
        lhs, lhs_params = self.process_lhs(qn, connection)
        rhs, rhs_params = self.process_rhs(qn, connection)
        return '%s LIKE %s' % (lhs, rhs), lhs_params + rhs_params

Field.register_lookup(Like)


class ILike(Lookup):
    lookup_name = 'ilike'

    def as_postgresql(self, qn, connection):
        lhs, lhs_params = self.process_lhs(qn, connection)
        rhs, rhs_params = self.process_rhs(qn, connection)
        return '%s ILIKE %s' % (lhs, rhs), lhs_params + rhs_params
Field.register_lookup(ILike)


class NetFilter(Lookup):
    lookup_name = 'netfilter'

    def as_postgresql(self, qn, connection):
        lhs, lhs_params = self.process_lhs(qn, connection)
        rhs, rhs_params = self.process_rhs(qn, connection)
        params = lhs_params + rhs_params
        return "%s <<= inet %s" % (lhs, rhs), params
Field.register_lookup(NetFilter)


class DateLookup(Lookup):
    lookup_name = 'date' 

    def as_sql(self, compiler, connection):
        lhs, lhs_params = self.process_lhs(compiler, connection)
        rhs, rhs_params = self.process_rhs(compiler, connection)
        params = lhs_params + rhs_params
        return 'DATE(%s) = %s' % (lhs, rhs), params
DateField.register_lookup(DateLookup)
DateTimeField.register_lookup(DateLookup)

class SplitDomain(Transform):
    lookup_name = 'splitdomain'

    def as_postgresql(self, qn, connection):
        lhs, params = qn.compile(self.lhs)
        return "split_part(%s,'@',1)" % lhs, params
Field.register_lookup(SplitDomain)

#import operator
#from django.db.models import Q
#
#q = ['x', 'y', 'z']
#query = reduce(operator.and_, (Q(first_name__contains = item) for item in ['x', 'y', 'z']))
#result = User.objects.filter(query)
#

